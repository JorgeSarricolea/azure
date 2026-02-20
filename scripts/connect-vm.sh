#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Select VM (default: VM1)
VM_SELECT="${1:-1}"

case "$VM_SELECT" in
    1|vm1)
        TARGET_IP="$VM1_IP"
        TARGET_NAME="$VM1_NAME"
        ;;
    2|vm2)
        TARGET_IP="$VM2_IP"
        TARGET_NAME="$VM2_NAME"
        ;;
    *)
        echo "Usage: $0 [1|2]"
        echo "  1, vm1  - Connect to VM1 (default)"
        echo "  2, vm2  - Connect to VM2"
        exit 1
        ;;
esac

echo "Connecting to $TARGET_NAME ($TARGET_IP)..."
sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$TARGET_IP"
