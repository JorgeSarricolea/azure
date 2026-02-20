#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Select VM (default: both)
VM_SELECT="${1:-all}"

stop_vm() {
    local vm_name=$1
    
    echo "Stopping $vm_name..."
    STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
    
    if [[ "$STATUS" == *"deallocated"* ]]; then
        echo "  $vm_name: Already stopped"
        return 0
    fi
    
    az vm deallocate --resource-group "$RESOURCE_GROUP" --name "$vm_name" --no-wait 2>/dev/null
    echo "  $vm_name: Stopping..."
}

wait_for_stop() {
    local vm_name=$1
    
    for i in {1..12}; do
        STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
        if [[ "$STATUS" == *"deallocated"* ]]; then
            echo "  $vm_name: Stopped"
            return 0
        fi
        sleep 5
    done
    echo "  $vm_name: Still stopping..."
}

echo "=== Stopping Azure VMs ==="
echo ""

case "$VM_SELECT" in
    1|vm1)
        stop_vm "$VM1_NAME"
        echo ""
        echo "Waiting..."
        wait_for_stop "$VM1_NAME"
        ;;
    2|vm2)
        stop_vm "$VM2_NAME"
        echo ""
        echo "Waiting..."
        wait_for_stop "$VM2_NAME"
        ;;
    all|both)
        stop_vm "$VM1_NAME"
        stop_vm "$VM2_NAME"
        echo ""
        echo "Waiting for VMs to stop..."
        sleep 15
        wait_for_stop "$VM1_NAME"
        wait_for_stop "$VM2_NAME"
        ;;
    *)
        echo "Usage: $0 [1|2|all]"
        echo "  1, vm1  - Stop VM1 only"
        echo "  2, vm2  - Stop VM2 only"
        echo "  all     - Stop both VMs (default)"
        exit 1
        ;;
esac

echo ""
echo "Note: No charges while VMs are deallocated."
echo "=== Done ==="
