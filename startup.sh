#!/bin/bash

# Update system
apt update -y
apt install -y python3 python3-pip python3-venv git

# Create app directory
mkdir -p /opt/fastapi-app
cd /opt/fastapi-app

# Clone from GitHub repo for code
git clone https://github.com/Pradip240/GCP-Autoscaling-and-Security.git .

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create systemd service for production-style startup
cat <<EOF > /etc/systemd/system/fastapi.service
[Unit]
Description=FastAPI App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/fastapi-app
ExecStart=/opt/fastapi-app/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start service
systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi