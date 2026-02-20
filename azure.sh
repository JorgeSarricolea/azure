#!/bin/bash

# Azure Lab - Main Entry Point
# Usage: ./azure.sh <command> [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

show_help() {
    echo "Azure Lab - Comandos disponibles:"
    echo ""
    echo "  Administración de VMs:"
    echo "    ./azure.sh start [1|2|all]     - Encender VMs"
    echo "    ./azure.sh stop [1|2|all]      - Apagar VMs"
    echo "    ./azure.sh check [1|2|all]     - Verificar estado"
    echo "    ./azure.sh ssh [1|2]           - Conectar por SSH"
    echo ""
    echo "  Despliegue:"
    echo "    ./azure.sh deploy [1|2|all]    - Subir archivos web"
    echo "    ./azure.sh install [1|2|all]   - Instalar Apache+PHP"
    echo ""
    echo "  Otros:"
    echo "    ./azure.sh test                - Probar páginas web"
    echo "    ./azure.sh help                - Mostrar esta ayuda"
    echo ""
    echo "  URLs:"
    echo "    App Service: https://webapp-jorge-sarricolea.azurewebsites.net"
    echo "    VM1: http://40.75.72.35"
    echo "    VM2: http://20.96.33.225"
}

case "$1" in
    start)
        "$SCRIPTS_DIR/start-vm.sh" "${@:2}"
        ;;
    stop)
        "$SCRIPTS_DIR/stop-vm.sh" "${@:2}"
        ;;
    check)
        "$SCRIPTS_DIR/check-vm.sh" "${@:2}"
        ;;
    ssh|connect)
        "$SCRIPTS_DIR/connect-vm.sh" "${@:2}"
        ;;
    deploy)
        "$SCRIPTS_DIR/deploy.sh" "${@:2}"
        ;;
    install)
        "$SCRIPTS_DIR/install-lamp.sh" "${@:2}"
        ;;
    test)
        "$SCRIPTS_DIR/test-php.sh" "${@:2}"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "Comando no reconocido: $1"
        echo "Usa './azure.sh help' para ver los comandos disponibles."
        exit 1
        ;;
esac
