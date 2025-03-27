#!/bin/bash

# Define variables
EXPORTER_VERSION="1.3.0"
EXPORTER_NAME="nvidia_gpu_exporter-${EXPORTER_VERSION}.linux-amd64"
EXPORTER_TARBALL="${EXPORTER_NAME}.tar.gz"
DOWNLOAD_URL="https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${EXPORTER_VERSION}/${EXPORTER_TARBALL}"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/nvidia_gpu_exporter.service"

# Download the NVIDIA GPU Exporter tarball
wget -q $DOWNLOAD_URL -O $EXPORTER_TARBALL

# Verify the download
if [ ! -f "$EXPORTER_TARBALL" ]; then
    echo "Download failed: $EXPORTER_TARBALL not found."
    exit 1
fi

# Extract the tarball
tar -xzf $EXPORTER_TARBALL

# Move the binary to the installation directory
sudo mv $EXPORTER_NAME/nvidia_gpu_exporter $INSTALL_DIR/

# Clean up
rm -rf $EXPORTER_NAME $EXPORTER_TARBALL

# Create a systemd service file
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=NVIDIA GPU Exporter
After=network.target

[Service]
ExecStart=$INSTALL_DIR/nvidia_gpu_exporter
User=nobody
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable and start the NVIDIA GPU Exporter service
sudo systemctl enable nvidia_gpu_exporter
sudo systemctl start nvidia_gpu_exporter

echo "NVIDIA GPU Exporter installation and service setup complete."
