#!/bin/bash
set -e

echo "=== Step 1: Install curl and dependencies ==="
sudo apt update
sudo apt install -y curl apt-transport-https ca-certificates gnupg

echo "=== Step 2: Install Google Cloud Ops Agent ==="
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

echo "=== Step 3: Verify Ops Agent is running ==="
sudo systemctl status google-cloud-ops-agent || echo "Ops Agent not running!"

echo "=== Step 4: Install Google Cloud CLI (gcloud) ==="
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt update
sudo apt install -y google-cloud-cli

echo "=== Step 5: Authenticate gcloud to GCP ==="
echo "This will open a browser. Complete login to allow the Ops Agent to push metrics."
gcloud auth application-default login

echo "=== Setup complete! ==="
echo "You can now view CPU metrics in GCP Monitoring → Metrics Explorer → agent.googleapis.com/cpu/utilization"