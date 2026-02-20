#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Select VM (default: both)
VM_SELECT="${1:-all}"

check_vm() {
    local vm_name=$1
    local vm_ip=$2
    local vm_private_ip=$3
    
    echo "=== $vm_name ==="
    
    # Check Azure status
    STATUS=$(az vm get-instance-view --resource-group "$RESOURCE_GROUP" --name "$vm_name" --query "instanceView.statuses[1].displayStatus" -o tsv 2>/dev/null)
    
    if [ -z "$STATUS" ]; then
        echo "Error: Could not get VM status. Run 'az login' first."
        return 1
    fi
    
    echo "Azure Status: $STATUS"
    echo "Public IP: $vm_ip"
    echo "Private IP: $vm_private_ip"
    
    if [[ "$STATUS" != *"running"* ]]; then
        echo "VM is not running."
        echo ""
        return 0
    fi
    
    # Get details via SSH
    echo ""
    sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10 "$VM_USER@$vm_ip" 'bash -s' 2>/dev/null << 'EOF'
echo "OS: $(lsb_release -ds 2>/dev/null || echo 'Unknown')"
echo "Uptime: $(uptime -p)"
echo "CPU: $(nproc) cores | RAM: $(free -h | awk '/Mem:/{print $3"/"$2}')"
echo ""
echo "Services:"
echo "  Apache: $(systemctl is-active apache2 2>/dev/null || echo 'not installed')"
echo "  PHP: $(php -v 2>/dev/null | head -1 | awk '{print $2}' || echo 'not installed')"
echo "  MySQL: $(systemctl is-active mysql 2>/dev/null || echo 'not installed')"
EOF
    echo ""
}

echo "========================================"
echo "       AZURE VMs STATUS CHECK"
echo "========================================"
echo ""

case "$VM_SELECT" in
    1|vm1)
        check_vm "$VM1_NAME" "$VM1_IP" "$VM1_PRIVATE_IP"
        ;;
    2|vm2)
        check_vm "$VM2_NAME" "$VM2_IP" "$VM2_PRIVATE_IP"
        ;;
    all|both)
        check_vm "$VM1_NAME" "$VM1_IP" "$VM1_PRIVATE_IP"
        check_vm "$VM2_NAME" "$VM2_IP" "$VM2_PRIVATE_IP"
        ;;
    *)
        echo "Usage: $0 [1|2|all]"
        echo "  1, vm1  - Check VM1 only"
        echo "  2, vm2  - Check VM2 only"
        echo "  all     - Check both VMs (default)"
        exit 1
        ;;
esac

echo "========================================"
