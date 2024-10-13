#!/bin/bash

# Check if enough arguments are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <id> <storage-name> <size>[M|G|T]"
    echo "Example: $0 101 local 40G"
    exit 1
fi

# Assign arguments to variables
ID=$1
STORAGE=$2
SIZE=$3

# Validate the size format (should end with M, G, or T)
if [[ ! $SIZE =~ ^[0-9]+[MGT]$ ]]; then
    echo "Error: Size must be a number followed by M (MB), G (GB), or T (TB)"
    exit 1
fi

# Convert size to GB if needed
case "${SIZE: -1}" in
    M)
        # Convert MB to GB
        SIZE_GB=$(echo "${SIZE%M} / 1024" | bc -l)
        ;;
    G)
        SIZE_GB=${SIZE%G} # No conversion needed for GB
        ;;
    T)
        # Convert TB to GB
        SIZE_GB=$(echo "${SIZE%T} * 1024" | bc -l)
        ;;
    *)
        echo "Invalid size unit. Use M for MB, G for GB, or T for TB."
        exit 1
        ;;
esac

# Stop the container
pct stop $ID

# Backup the container
vzdump $ID -storage local -compress lzo

# Destroy the container
pct destroy $ID

# Restore the container with the specified rootfs size and storage
pct restore $ID /var/lib/vz/dump/vzdump-lxc-$ID...tar.lzo --rootfs ${SIZE_GB} --unprivileged --storage $STORAGE

# Echo the size in GB
echo "Container $ID restored and resized to $SIZE_GB GB on storage $STORAGE."
