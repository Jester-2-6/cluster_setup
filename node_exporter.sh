#!/bin/bash

# Define variables
NODE_EXPORTER_VERSION="1.6.1"
NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_GROUP="node_exporter"
NODE_EXPORTER_HOME="/home/node_exporter"

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y wget

# Create a system user for node_exporter
sudo useradd --system --no-create-home --shell /bin/false $NODE_EXPORTER_USER

# Download and extract Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Move the binary to /usr/local/bin
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

# Set ownership and permissions
sudo chown $NODE_EXPORTER_USER:$NODE_EXPORTER_GROUP /usr/local/bin/node_exporter

# Clean up
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*
cd ~

# Create systemd service file
sudo bash -c "cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$NODE_EXPORTER_USER
Group=$NODE_EXPORTER_GROUP
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd, enable and start node_exporter service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "Node Exporter installation and setup completed successfully."
