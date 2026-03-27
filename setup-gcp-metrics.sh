#!/bin/bash
set -e

# ==========================================
# CONFIGURATION - UPDATE THESE VARIABLES
# ==========================================
PROJECT_ID="vcc-m25ai2016"
SA_KEY_PATH="/tmp/sa-key.json" # <--- UPDATE THIS PATH to your downloaded JSON key
GCP_AUTH_DIR="/etc/google/auth"
GCP_CREDS_FILE="$GCP_AUTH_DIR/application_default_credentials.json"
CUSTOM_SCRIPT_LOG="/path/to/your/script.log" # <--- UPDATE THIS if you want to tail a specific script

if [ ! -f "$SA_KEY_PATH" ]; then
    echo "Error: Service account key not found at $SA_KEY_PATH!"
    echo "Please download the JSON key and update the SA_KEY_PATH variable."
    exit 1
fi

echo "=== Step 1: Clean up old Ops Agent (if present) ==="
sudo apt-get remove --purge -y google-cloud-ops-agent || true
sudo rm -rf /etc/systemd/system/google-cloud-ops-agent*.service.d
sudo rm -rf /etc/systemd/system.conf.d/ops-agent-bms.conf

echo "=== Step 2: Configure GCP Credentials ==="
sudo mkdir -p $GCP_AUTH_DIR
sudo cp "$SA_KEY_PATH" "$GCP_CREDS_FILE"
sudo chmod 644 "$GCP_CREDS_FILE"

echo "=== Step 3: Install Fluent Bit ==="
curl -sS https://raw.githubusercontent.com/Fluent/fluent-bit/master/install.sh | sh

echo "=== Step 4: Configure Fluent Bit for GCP Stackdriver ==="
cat <<EOF | sudo tee /etc/fluent-bit/fluent-bit.conf
[SERVICE]
    Flush        1
    Log_Level    info

# Watch standard system logs
[INPUT]
    Name         tail
    Path         /var/log/syslog
    Tag          syslog

# Watch your custom script logs
[INPUT]
    Name         tail
    Path         $CUSTOM_SCRIPT_LOG
    Tag          my_custom_script

# Export everything to Google Cloud Logging
[OUTPUT]
    Name                  stackdriver
    Match                 *
    resource              generic_node
    export_to_project_id  $PROJECT_ID
    location              us-central1
    namespace             local-vm
    node_id               m25ai2016-local
EOF

echo "=== Step 5: Inject GCP Credentials into systemd ==="
sudo mkdir -p /etc/systemd/system/fluent-bit.service.d
cat <<EOF | sudo tee /etc/systemd/system/fluent-bit.service.d/override.conf
[Service]
Environment="GOOGLE_APPLICATION_CREDENTIALS=$GCP_CREDS_FILE"
EOF

echo "=== Step 6: Reload and Restart Services ==="
sudo systemctl daemon-reload
sudo systemctl enable fluent-bit
sudo systemctl restart fluent-bit

echo "=== Setup Complete! ==="
echo "Checking Fluent Bit status for 5 seconds to ensure clean startup..."
sleep 5
sudo journalctl -u fluent-bit -n 15 --no-pager

echo ""
echo "If you see '[oauth2] HTTP Status=200', you are good to go!"
echo "View your logs in Google Cloud Console -> Logging -> Logs Explorer"