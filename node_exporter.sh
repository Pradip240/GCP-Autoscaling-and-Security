#!/bin/bash
set -e

NODE_EXPORTER_VERSION="1.8.1"
INSTALL_DIR="/opt/node_exporter"

echo "Installing Node Exporter v${NODE_EXPORTER_VERSION}..."

cd /opt

# Download only if not already present
if [ ! -d "$INSTALL_DIR" ]; then
  wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  tar xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
fi

# Detect init system
INIT_SYSTEM=$(ps -p 1 -o comm=)

echo "Detected init system: $INIT_SYSTEM"

# -------------------------------
# systemd setup
# -------------------------------
if [[ "$INIT_SYSTEM" == "systemd" ]]; then

  echo "Configuring systemd service..."

  cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=${INSTALL_DIR}/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable node_exporter
  systemctl restart node_exporter

# -------------------------------
# OpenRC setup (Alpine)
# -------------------------------
elif [[ "$INIT_SYSTEM" == "openrc" ]] || [ -d /run/openrc ]; then

  echo "Configuring OpenRC service..."

  cat <<EOF > /etc/init.d/node_exporter
#!/sbin/openrc-run

name="node_exporter"
description="Prometheus Node Exporter"

command="${INSTALL_DIR}/node_exporter"
command_background=true
pidfile="/run/node_exporter.pid"

depend() {
    need net
}
EOF

  chmod +x /etc/init.d/node_exporter
  rc-update add node_exporter default
  rc-service node_exporter restart

# -------------------------------
# Fallback (containers / minimal OS)
# -------------------------------
else
  echo "No supported init system found. Running in background..."

  nohup ${INSTALL_DIR}/node_exporter > /var/log/node_exporter.log 2>&1 &
fi

echo "Node Exporter setup complete."