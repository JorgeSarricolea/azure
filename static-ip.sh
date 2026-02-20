#!/bin/bash

# Load VM configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

AZ="az"
# Uses RESOURCE_GROUP and VM1_NAME from config.sh
VM_NAME="$VM1_NAME"

echo "=== Azure Static IP Configuration ==="
echo ""

# Check if logged in
if ! $AZ account show > /dev/null 2>&1; then
    echo "Not logged in. Run: az login"
    exit 1
fi

echo "Finding public IP for VM: $VM_NAME..."

# Get public IP name from VM's NIC
NIC_ID=$($AZ vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "networkProfile.networkInterfaces[0].id" -o tsv 2>/dev/null)
PIP_ID=$($AZ network nic show --ids "$NIC_ID" --query "ipConfigurations[0].publicIPAddress.id" -o tsv 2>/dev/null)
PIP_NAME=$(basename "$PIP_ID")

if [ -z "$PIP_NAME" ]; then
    echo "Error: Could not find public IP"
    exit 1
fi

echo "Public IP resource: $PIP_NAME"

# Check current allocation method
CURRENT=$($AZ network public-ip show -g "$RESOURCE_GROUP" -n "$PIP_NAME" --query "publicIPAllocationMethod" -o tsv 2>/dev/null)
echo "Current allocation: $CURRENT"

if [ "$CURRENT" == "Static" ]; then
    echo ""
    echo "IP is already static: $VM_IP"
    echo "Done!"
else
    echo ""
    echo "Changing to Static..."
    $AZ network public-ip update -g "$RESOURCE_GROUP" -n "$PIP_NAME" --allocation-method Static > /dev/null 2>&1
    
    NEW_IP=$($AZ network public-ip show -g "$RESOURCE_GROUP" -n "$PIP_NAME" --query "ipAddress" -o tsv 2>/dev/null)
    echo "Done! Static IP: $NEW_IP"
fi
