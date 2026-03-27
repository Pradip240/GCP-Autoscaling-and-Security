#!/bin/bash

# --- CONFIGURATION ---
THRESHOLD=75
PROJECT_ID="vcc-m25ai2016"
TEMPLATE_NAME="autoscale-app-template"
REGION="asia-south1" 
ZONE="asia-south1-a" 
KEY_FILE="/home/pradip/autoscale-key.json"
LOCK_FILE="/tmp/gcp_scaling.lock"

# 1. Clear environment and Authenticate
unset GOOGLE_APPLICATION_CREDENTIALS
gcloud auth activate-service-account --key-file="$KEY_FILE" --quiet
gcloud config set project "$PROJECT_ID" --quiet

# 2. Get CPU
CPU_USAGE=$(mpstat 2 1 | awk '/Average/ {print 100 - $NF}' | cut -d. -f1)
echo "Current local CPU Usage: ${CPU_USAGE}%"

if [ "$CPU_USAGE" -gt "$THRESHOLD" ]; then
    if [ -f "$LOCK_FILE" ]; then
        echo "A GCP VM was already triggered recently. Waiting..."
        exit 0
    fi

    echo "WARNING: CPU exceeded ${THRESHOLD}%. Triggering GCP Cloud Burst!"
    touch "$LOCK_FILE"
    
    INSTANCE_NAME="burst-vm-$(date +%s)"
    
    # --- THE FULL PATH FIX ---
    # We combine the project, region, and template into one long string
    FULL_TEMPLATE_PATH="projects/$PROJECT_ID/regions/$REGION/instanceTemplates/$TEMPLATE_NAME"
    
    if gcloud compute instances create "$INSTANCE_NAME" \
        --project="$PROJECT_ID" \
        --zone="$ZONE" \
        --source-instance-template="$FULL_TEMPLATE_PATH"; then
        
        echo "Success! Instance $INSTANCE_NAME is booting up."
        # Remove lock file after 10 minutes
        (sleep 600 && rm -f "$LOCK_FILE") &
    else
        echo "ERROR: GCP failed to create the instance!"
        rm -f "$LOCK_FILE"
    fi
else
    echo "CPU is normal."
fi