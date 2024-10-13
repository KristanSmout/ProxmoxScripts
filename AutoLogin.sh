#!/bin/bash

# Define the directory and file path
DIR="/etc/systemd/system/container-getty@1.service.d"
FILE="$DIR/override.conf"

# Check if the directory exists, if not, create it
if [ ! -d "$DIR" ]; then
    echo "Directory $DIR does not exist. Creating..."
    mkdir -p "$DIR"
fi

# Check if the file exists, if not, create it and write the content
if [ ! -f "$FILE" ]; then
    echo "File $FILE does not exist. Creating and writing content..."
    cat <<EOL > "$FILE"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOL
else
    echo "File $FILE already exists."
fi

# Optionally, reload the systemd daemon to apply the changes
systemctl daemon-reload

echo "Script completed."
