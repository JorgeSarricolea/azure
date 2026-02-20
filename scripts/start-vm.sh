#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Select VM (default: both)
VM_SELECT="${1:-all}"

start_vm() {
    local vm_name=$1
    
    echo "Starting $vm_name..."
    STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
    
    if [[ "$STATUS" == *"running"* ]]; then
        IP=$(az vm list-ip-addresses --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>/dev/null)
        echo "  $vm_name: Already running ($IP)"
        return 0
    fi
    
    az vm start --resource-group "$RESOURCE_GROUP" --name "$vm_name" --no-wait 2>/dev/null
    echo "  $vm_name: Starting..."
}

wait_for_vm() {
    local vm_name=$1
    
    for i in {1..12}; do
        STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
        if [[ "$STATUS" == *"running"* ]]; then
            IP=$(az vm list-ip-addresses --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv 2>/dev/null)
            echo "  $vm_name: Running ($IP)"
            return 0
        fi
        sleep 5
    done
    echo "  $vm_name: Still starting..."
}

echo "=== Starting Azure VMs ==="
echo ""

case "$VM_SELECT" in
    1|vm1)
        start_vm "$VM1_NAME"
        echo ""
        echo "Waiting..."
        wait_for_vm "$VM1_NAME"
        ;;
    2|vm2)
        start_vm "$VM2_NAME"
        echo ""
        echo "Waiting..."
        wait_for_vm "$VM2_NAME"
        ;;
    all|both)
        start_vm "$VM1_NAME"
        start_vm "$VM2_NAME"
        echo ""
        echo "Waiting for VMs to start..."
        sleep 20
        wait_for_vm "$VM1_NAME"
        wait_for_vm "$VM2_NAME"
        ;;
    *)
        echo "Usage: $0 [1|2|all]"
        echo "  1, vm1  - Start VM1 only"
        echo "  2, vm2  - Start VM2 only"
        echo "  all     - Start both VMs (default)"
        exit 1
        ;;
esac

echo ""
echo "=== Web Pages ==="
case "$VM_SELECT" in
    1|vm1)
        echo "  VM1: http://$VM1_IP"
        ;;
    2|vm2)
        echo "  VM2: http://$VM2_IP"
        ;;
    all|both)
        echo "  VM1: http://$VM1_IP"
        echo "  VM2: http://$VM2_IP"
        ;;
esac
echo ""
echo "=== Done ==="
