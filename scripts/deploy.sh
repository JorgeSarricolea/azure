#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/config.sh"

# Select VM (default: VM1)
VM_SELECT="${1:-1}"

case "$VM_SELECT" in
    1|vm1)
        TARGET_IP="$VM1_IP"
        TARGET_NAME="$VM1_NAME"
        WEB_DIR="$PROJECT_DIR/vm1-web"
        ;;
    2|vm2)
        TARGET_IP="$VM2_IP"
        TARGET_NAME="$VM2_NAME"
        WEB_DIR="$PROJECT_DIR/vm2-web"
        ;;
    all|both)
        echo "=== Deploying to both VMs ==="
        "$0" 1
        echo ""
        "$0" 2
        exit 0
        ;;
    *)
        echo "Usage: $0 [1|2|all]"
        echo "  1, vm1  - Deploy vm1-web/ to VM1 (default)"
        echo "  2, vm2  - Deploy vm2-web/ to VM2"
        echo "  all     - Deploy to both VMs"
        exit 1
        ;;
esac

echo "=== Deploying to $TARGET_NAME ==="
echo ""

# Check if web folder exists
if [ ! -d "$WEB_DIR" ]; then
    echo "Error: $(basename $WEB_DIR)/ folder not found"
    exit 1
fi

# Count files to deploy
FILE_COUNT=$(find "$WEB_DIR" -type f | wc -l | tr -d ' ')
echo "Source: $(basename $WEB_DIR)/"
echo "Files: $FILE_COUNT"
echo "Target: $VM_USER@$TARGET_IP:/var/www/html/"
echo ""

# Upload files
echo "Uploading..."
sshpass -p "$VM_PASSWORD" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -r "$WEB_DIR"/* "$VM_USER@$TARGET_IP":/tmp/ 2>/dev/null

# Move files to /var/www/html with sudo
sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "$VM_USER@$TARGET_IP" 'sudo cp -r /tmp/*.php /tmp/*.html /tmp/*.css /tmp/*.js /var/www/html/ 2>/dev/null; sudo rm -f /tmp/*.php /tmp/*.html /tmp/*.css /tmp/*.js 2>/dev/null' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Done!"
    echo ""
    echo "View at: http://$TARGET_IP"
else
    echo "Error uploading files"
    exit 1
fi
