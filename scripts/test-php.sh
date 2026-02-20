#!/bin/bash

# Load VM configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=== PHP Welcome Page Status ==="
echo ""

test_vm() {
    local vm_name=$1
    local vm_ip=$2
    
    echo "--- $vm_name ($vm_ip) ---"
    
    # Test externally
    RESPONSE=$(curl -s --connect-timeout 5 "http://$vm_ip" 2>/dev/null | head -5)
    
    if echo "$RESPONSE" | grep -q "html"; then
        echo "  Status: OK - Page accessible"
        echo "  URL: http://$vm_ip"
    else
        echo "  Status: ERROR - Not accessible"
    fi
    echo ""
}

test_vm "$VM1_NAME" "$VM1_IP"
test_vm "$VM2_NAME" "$VM2_IP"
