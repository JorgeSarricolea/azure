#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"

run_on_vm() {
    local ip=$1
    shift
    sshpass -p "$VM_PASSWORD" ssh $SSH_OPTS "$VM_USER@$ip" "$@" 2>/dev/null
}

print_section() {
    echo ""
    echo "──────────────────────────────────────────"
    echo "  $1"
    echo "──────────────────────────────────────────"
}

echo "╔══════════════════════════════════════════╗"
echo "║   PRUEBA DE CONECTIVIDAD ENTRE VMs       ║"
echo "║   Azure Virtual Network - East US 2      ║"
echo "╚══════════════════════════════════════════╝"

# ── Test 1: Ping from VM1 to VM2 ──
print_section "TEST 1: Ping VM1 (172.16.0.4) → VM2 (172.16.1.4)"

PING_RESULT=$(run_on_vm "$VM1_IP" "ping -c 3 -W 2 $VM2_PRIVATE_IP 2>&1")
if echo "$PING_RESULT" | grep -q "bytes from"; then
    echo "$PING_RESULT"
    echo ""
    echo "  [PASS] VM1 puede comunicarse con VM2 via ICMP"
else
    echo "$PING_RESULT"
    echo ""
    echo "  [FAIL] VM1 NO puede hacer ping a VM2"
fi

# ── Test 2: Ping from VM2 to VM1 ──
print_section "TEST 2: Ping VM2 (172.16.1.4) → VM1 (172.16.0.4)"

PING_RESULT=$(run_on_vm "$VM2_IP" "ping -c 3 -W 2 $VM1_PRIVATE_IP 2>&1")
if echo "$PING_RESULT" | grep -q "bytes from"; then
    echo "$PING_RESULT"
    echo ""
    echo "  [PASS] VM2 puede comunicarse con VM1 via ICMP"
else
    echo "$PING_RESULT"
    echo ""
    echo "  [FAIL] VM2 NO puede hacer ping a VM1"
fi

# ── Test 3: HTTP from VM1 to VM2 ──
print_section "TEST 3: HTTP VM1 → VM2 (curl al servidor web)"

HTTP_RESULT=$(run_on_vm "$VM1_IP" "curl -s -o /dev/null -w 'HTTP %{http_code} | Tiempo: %{time_total}s' --connect-timeout 5 http://$VM2_PRIVATE_IP 2>&1")
if echo "$HTTP_RESULT" | grep -q "HTTP 200"; then
    echo "  Respuesta: $HTTP_RESULT"
    echo ""
    echo "  [PASS] VM1 puede acceder al servidor web de VM2"
else
    echo "  Respuesta: $HTTP_RESULT"
    echo ""
    echo "  [FAIL] VM1 NO puede acceder al servidor web de VM2"
fi

# ── Test 4: HTTP from VM2 to VM1 ──
print_section "TEST 4: HTTP VM2 → VM1 (curl al servidor web)"

HTTP_RESULT=$(run_on_vm "$VM2_IP" "curl -s -o /dev/null -w 'HTTP %{http_code} | Tiempo: %{time_total}s' --connect-timeout 5 http://$VM1_PRIVATE_IP 2>&1")
if echo "$HTTP_RESULT" | grep -q "HTTP 200"; then
    echo "  Respuesta: $HTTP_RESULT"
    echo ""
    echo "  [PASS] VM2 puede acceder al servidor web de VM1"
else
    echo "  Respuesta: $HTTP_RESULT"
    echo ""
    echo "  [FAIL] VM2 NO puede acceder al servidor web de VM1"
fi

# ── Test 5: Traceroute (shows same-VNet, no external hops) ──
print_section "TEST 5: Traceroute VM1 → VM2 (ruta de red)"

TRACE_RESULT=$(run_on_vm "$VM1_IP" "traceroute -n -m 5 -w 2 $VM2_PRIVATE_IP 2>&1 || tracepath -n $VM2_PRIVATE_IP 2>&1 | head -5")
echo "$TRACE_RESULT"
echo ""
echo "  (Pocos saltos = comunicacion directa dentro de la VNet)"

# ── Summary ──
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║              RESUMEN                      ║"
echo "╠══════════════════════════════════════════╣"
echo "║  VNet:    vnet-eastus2 (172.16.0.0/16)   ║"
echo "║  VM1:     Subnet 1 - 172.16.0.4          ║"
echo "║  VM2:     Subnet 2 - 172.16.1.4          ║"
echo "║                                           ║"
echo "║  Las VMs en diferentes subnets pueden     ║"
echo "║  comunicarse dentro de la misma VNet.     ║"
echo "║  El trafico es privado (no sale a         ║"
echo "║  Internet).                               ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Ejecutado: $(date '+%d/%m/%Y %H:%M:%S')"
