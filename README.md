# Azure VM Lab - Práctica de Redes

Proyecto de práctica para crear y administrar máquinas virtuales en Azure con configuración de red.

## Configuración Inicial

1. Clona el repositorio
2. Copia el archivo de configuración:
   ```bash
   cp config.sh.example config.sh
   ```
3. Edita `config.sh` con tus credenciales reales

> ⚠️ **Importante:** `config.sh` contiene credenciales y está en `.gitignore`. Nunca subas este archivo.

## Arquitectura

```
Azure Subscription (Azure for Students - TECNM Mérida)
└── Resource Group: G-PRACTICA-VMS-01
    │
    └── VNet: vnet-eastus2 (172.16.0.0/16) - Region: East US 2
        │
        ├── Subnet 1: snet-eastus2-1 (172.16.0.0/24)
        │   └── VM-Windows-Practica-01
        │       ├── IP Privada: 172.16.0.4
        │       ├── IP Pública: 40.75.72.35
        │       ├── NSG: VM-Windows-Practica-01-nsg
        │       ├── OS: Ubuntu 24.04 LTS
        │       ├── Size: Standard_D2s_v3 (2 vCPUs, 8GB RAM)
        │       └── Servicios: Apache + PHP 8.3
        │
        └── Subnet 2: snet-eastus2-2 (172.16.1.0/24)
            └── VM-Practica-02
                ├── IP Privada: 172.16.1.4
                ├── IP Pública: 20.96.33.225
                ├── NSG: VM-Practica-02NSG
                ├── OS: Ubuntu 24.04 LTS
                └── Size: Standard_D2s_v3 (2 vCPUs, 8GB RAM)
```

## Credenciales

| Propiedad | Valor |
|-----------|-------|
| Usuario | azureadmin |
| Password | AzureLab2026! |

## Scripts Disponibles

Todos los scripts soportan selección de VM con argumentos: `1`, `2`, o `all`

### Administración de VMs

| Script | Descripción | Uso |
|--------|-------------|-----|
| `start-vm.sh` | Enciende VMs | `./start-vm.sh [1\|2\|all]` |
| `stop-vm.sh` | Apaga VMs (deallocate) | `./stop-vm.sh [1\|2\|all]` |
| `check-vm.sh` | Verifica estado y servicios | `./check-vm.sh [1\|2\|all]` |
| `connect-vm.sh` | Conecta por SSH | `./connect-vm.sh [1\|2]` |
| `config.sh` | Configuración central | (se carga automáticamente) |

### Despliegue Web

| Script | Descripción | Uso |
|--------|-------------|-----|
| `install-lamp.sh` | Instala Apache + PHP | `./install-lamp.sh [1\|2\|all]` |
| `deploy.sh` | Sube archivos a la VM | `./deploy.sh [1\|2\|all]` |
| `test-php.sh` | Verifica página PHP | `./test-php.sh` |

## Uso Rápido

### Encender las VMs
```bash
./start-vm.sh          # Ambas VMs
./start-vm.sh 1        # Solo VM1
./start-vm.sh 2        # Solo VM2
```

### Verificar estado
```bash
./check-vm.sh          # Ambas VMs
./check-vm.sh 1        # Solo VM1
```

### Conectar por SSH
```bash
./connect-vm.sh 1      # VM1 (default)
./connect-vm.sh 2      # VM2
```

### Desplegar cambios web
```bash
# Editar archivos en welcome-page/
./deploy.sh            # Solo VM1 (default)
./deploy.sh all        # Ambas VMs
```

### Instalar Apache + PHP
```bash
./install-lamp.sh 2    # Instalar en VM2
./install-lamp.sh all  # Ambas VMs
```

### Apagar VMs (ahorra costos)
```bash
./stop-vm.sh           # Ambas VMs
./stop-vm.sh 1         # Solo VM1
```

## Comandos Azure CLI Utilizados

### Login
```bash
az login --use-device-code
```

### Crear Subnet
```bash
az network vnet subnet create \
  --resource-group G-PRACTICA-VMS-01 \
  --vnet-name vnet-eastus2 \
  --name snet-eastus2-2 \
  --address-prefix 172.16.1.0/24
```

### Crear VM
```bash
az vm create \
  --resource-group G-PRACTICA-VMS-01 \
  --name VM-Practica-02 \
  --location eastus2 \
  --image Ubuntu2404 \
  --size Standard_D2s_v3 \
  --vnet-name vnet-eastus2 \
  --subnet snet-eastus2-2 \
  --admin-username azureadmin \
  --admin-password "AzureLab2026!" \
  --public-ip-sku Standard
```

### Abrir Puerto 80 (HTTP)
```bash
az network nsg rule create \
  --resource-group G-PRACTICA-VMS-01 \
  --nsg-name VM-Windows-Practica-01-nsg \
  --name Allow-HTTP \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound
```

### Permitir Comunicación entre Subnets
```bash
# En cada NSG de las VMs
az network nsg rule create \
  --resource-group G-PRACTICA-VMS-01 \
  --nsg-name VM-Windows-Practica-01-nsg \
  --name Allow-VNet-Inbound \
  --priority 101 \
  --source-address-prefixes VirtualNetwork \
  --destination-address-prefixes VirtualNetwork \
  --destination-port-ranges '*' \
  --access Allow \
  --protocol '*' \
  --direction Inbound
```

### Listar VMs
```bash
az vm list --resource-group G-PRACTICA-VMS-01 --show-details -o table
```

### Ver IPs
```bash
az vm list-ip-addresses --resource-group G-PRACTICA-VMS-01 -o table
```

### Iniciar/Detener VMs
```bash
# Iniciar
az vm start --resource-group G-PRACTICA-VMS-01 --name VM-Windows-Practica-01

# Detener (deallocate - no cobra)
az vm deallocate --resource-group G-PRACTICA-VMS-01 --name VM-Windows-Practica-01
```

### Ver Estado de VM
```bash
az vm get-instance-view \
  --resource-group G-PRACTICA-VMS-01 \
  --name VM-Windows-Practica-01 \
  --query "instanceView.statuses[1].displayStatus" -o tsv
```

### Ver Cuotas de vCPUs
```bash
az vm list-usage --location eastus2 -o table
```

## Verificar Conectividad entre VMs

Desde VM1:
```bash
ping 172.16.1.4
```

Desde VM2:
```bash
ping 172.16.0.4
```

## URLs de Acceso

| Servicio | URL |
|----------|-----|
| Web VM1 | http://40.75.72.35 |
| Web VM2 | http://20.96.33.225 (requiere instalar Apache) |

## Despliegue Automático con GitHub Actions

El proyecto incluye un workflow que despliega automáticamente al hacer push a `main`.

### Configurar GitHub Secrets

En tu repositorio de GitHub, ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Valor |
|--------|-------|
| `VM1_IP` | IP pública de VM1 (ej: 40.75.72.35) |
| `VM2_IP` | IP pública de VM2 (ej: 20.96.33.225) |
| `VM_USER` | Usuario SSH (ej: azureadmin) |
| `VM_PASSWORD` | Contraseña SSH |

### Funcionamiento

1. Edita archivos en `vm1-web/` o `vm2-web/`
2. Haz commit y push a `main`
3. GitHub Actions despliega automáticamente a las VMs
4. Verifica el estado en la pestaña "Actions" del repo

> **Nota:** Las VMs deben estar encendidas para que el deploy funcione.

## Notas Importantes

1. **Costos**: Las VMs generan costos mientras están encendidas. Usa `./stop-vm.sh` cuando no las necesites.

2. **Cuota**: La suscripción de estudiante tiene límite de 4 vCPUs. Ambas VMs usan 2 cada una (4 total).

3. **Región**: Ambas VMs están en `eastus2`. La VNet y subnets deben estar en la misma región.

4. **NSG**: Los Network Security Groups controlan el tráfico. Por defecto bloquean todo excepto SSH (22).

5. **IPs Públicas**: Son estáticas (Standard SKU). No cambian al reiniciar.

## Estructura del Proyecto

```
azure/
├── .github/
│   └── workflows/
│       └── deploy.yml     # GitHub Actions para deploy automático
├── .gitignore             # Excluye config.sh
├── README.md              # Esta documentación
├── config.sh              # ⚠️ NO SUBIR - Credenciales reales
├── config.sh.example      # Template de configuración
├── vm1-web/               # Sitio web para VM1 (morado)
│   └── index.php
├── vm2-web/               # Sitio web para VM2 (verde)
│   └── index.php
├── check-vm.sh            # Verificar estado de VMs
├── connect-vm.sh          # Conexión SSH a VMs
├── deploy.sh              # Subir archivos a VMs (local)
├── install-lamp.sh        # Instalar Apache + PHP
├── start-vm.sh            # Encender VMs
├── stop-vm.sh             # Apagar VMs
├── static-ip.sh           # Configurar IP estática
└── test-php.sh            # Probar páginas PHP
```
