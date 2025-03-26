#!/bin/bash

# Prompt for NAS IP address
read -p "Enter the NAS IP address: " NAS_IP

# Prompt for dataset name
read -p "Enter the dataset name: " DATASET_NAME

# Define the mount point
MOUNT_POINT="/mnt/$DATASET_NAME"

# Create the mount point directory if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
fi

# Prompt for the share type (NFS or CIFS)
read -p "Enter the share type (nfs/cifs): " SHARE_TYPE

if [ "$SHARE_TYPE" == "nfs" ]; then
    # Define the NFS share path
    NFS_SHARE="$NAS_IP:/$DATASET_NAME"

    # Mount the NFS share
    sudo mount -t nfs "$NFS_SHARE" "$MOUNT_POINT"

    # Add to /etc/fstab for persistent mounting
    echo "$NFS_SHARE $MOUNT_POINT nfs defaults 0 0" | sudo tee -a /etc/fstab

elif [ "$SHARE_TYPE" == "cifs" ]; then
    # Prompt for CIFS credentials
    read -p "Enter the CIFS username: " CIFS_USER
    read -s -p "Enter the CIFS password: " CIFS_PASS
    echo

    # Create a credentials file
    CREDENTIALS_FILE="$HOME/.smbcredentials"
    echo "username=$CIFS_USER" > "$CREDENTIALS_FILE"
    echo "password=$CIFS_PASS" >> "$CREDENTIALS_FILE"
    chmod 600 "$CREDENTIALS_FILE"

    # Define the CIFS share path
    CIFS_SHARE="//$NAS_IP/$DATASET_NAME"

    # Install cifs-utils if not already installed
    if ! dpkg -l | grep -q cifs-utils; then
        sudo apt-get update
        sudo apt-get install -y cifs-utils
    fi

    # Mount the CIFS share
    sudo mount -t cifs "$CIFS_SHARE" "$MOUNT_POINT" -o credentials="$CREDENTIALS_FILE",uid=$(id -u),gid=$(id -g)

    # Add to /etc/fstab for persistent mounting
    echo "$CIFS_SHARE $MOUNT_POINT cifs credentials=$CREDENTIALS_FILE,uid=$(id -u),gid=$(id -g) 0 0" | sudo tee -a /etc/fstab

else
    echo "Invalid share type. Please enter 'nfs' or 'cifs'."
    exit 1
fi

echo "Mounting completed successfully."
