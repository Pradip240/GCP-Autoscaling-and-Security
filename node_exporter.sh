#!/bin/bash

# Install Node Exporter
cd /opt

NODE_EXPORTER_VERSION="1.8.1"

wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter

# Node Exporter Service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/opt/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Node Exporter
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
