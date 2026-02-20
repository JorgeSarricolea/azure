<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VM2 - Servidor Secundario | Azure Lab</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); 
            color: white; 
            min-height: 100vh;
            padding: 20px;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .vm-badge { 
            background: rgba(255,255,255,0.2); 
            padding: 8px 20px; 
            border-radius: 25px; 
            font-size: 0.9em; 
            display: inline-block;
            margin-bottom: 15px;
            border: 1px solid rgba(255,255,255,0.3);
        }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .subtitle { opacity: 0.9; font-size: 1.1em; }
        
        .card {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .card h2 {
            font-size: 1.3em;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .card h2::before {
            content: '';
            width: 4px;
            height: 20px;
            background: #FFD700;
            border-radius: 2px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .info-item {
            background: rgba(0,0,0,0.2);
            padding: 15px;
            border-radius: 10px;
        }
        .info-item .label {
            font-size: 0.85em;
            opacity: 0.8;
            margin-bottom: 5px;
        }
        .info-item .value {
            font-size: 1.1em;
            font-weight: 600;
        }
        
        .network-diagram {
            background: rgba(0,0,0,0.3);
            padding: 20px;
            border-radius: 10px;
            font-family: monospace;
            font-size: 0.9em;
            line-height: 1.6;
            overflow-x: auto;
        }
        .highlight { color: #FFD700; }
        .current { color: #98FB98; font-weight: bold; }
        
        .table-container {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255,255,255,0.2);
        }
        th {
            background: rgba(0,0,0,0.2);
            font-weight: 600;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            opacity: 0.8;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <span class="vm-badge">🖥️ VM2 - Subnet 2 (172.16.1.0/24)</span>
            <h1>Servidor Secundario</h1>
            <p class="subtitle">Práctica de Redes en Azure - Configuración Multi-Subnet</p>
        </div>

        <div class="card">
            <h2>Información del Servidor</h2>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Hostname</div>
                    <div class="value"><?php echo gethostname(); ?></div>
                </div>
                <div class="info-item">
                    <div class="label">IP Privada</div>
                    <div class="value"><?php echo $_SERVER['SERVER_ADDR']; ?></div>
                </div>
                <div class="info-item">
                    <div class="label">PHP Version</div>
                    <div class="value"><?php echo phpversion(); ?></div>
                </div>
                <div class="info-item">
                    <div class="label">Sistema Operativo</div>
                    <div class="value">Ubuntu 24.04 LTS</div>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Arquitectura de Red</h2>
            <div class="network-diagram">
<span class="highlight">Azure Virtual Network (VNet)</span>
├── Nombre: vnet-eastus2
├── Región: East US 2
└── Address Space: <span class="highlight">172.16.0.0/16</span>
    │
    ├── Subnet 1: snet-eastus2-1 (172.16.0.0/24)
    │   └── VM1 (Servidor Principal) - 172.16.0.4
    │
    └── <span class="current">► Subnet 2: snet-eastus2-2 (172.16.1.0/24)</span>
        └── <span class="current">VM2 (Este servidor) - 172.16.1.4</span>
            </div>
        </div>

        <div class="card">
            <h2>Configuración de Network Security Group (NSG)</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Regla</th>
                            <th>Puerto</th>
                            <th>Protocolo</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Allow-SSH</td>
                            <td>22</td>
                            <td>TCP</td>
                            <td>✅ Permitir</td>
                        </tr>
                        <tr>
                            <td>Allow-HTTP</td>
                            <td>80</td>
                            <td>TCP</td>
                            <td>✅ Permitir</td>
                        </tr>
                        <tr>
                            <td>Allow-VNet-Inbound</td>
                            <td>*</td>
                            <td>*</td>
                            <td>✅ Permitir (VNet)</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <h2>Beneficios de la Segmentación por Subnets</h2>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">🔒 Aislamiento</div>
                    <div class="value">Separación lógica de recursos</div>
                </div>
                <div class="info-item">
                    <div class="label">🛡️ Seguridad</div>
                    <div class="value">NSG por subnet para control granular</div>
                </div>
                <div class="info-item">
                    <div class="label">📊 Organización</div>
                    <div class="value">Agrupar recursos por función</div>
                </div>
                <div class="info-item">
                    <div class="label">🔄 Escalabilidad</div>
                    <div class="value">Fácil expansión de la red</div>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Conectividad en Vivo con VM1</h2>
            <p style="margin-bottom: 15px;">Prueba en tiempo real de comunicación con VM1 (172.16.0.4):</p>
            <?php
                $vm1_ip = '172.16.0.4';

                $ping_output = shell_exec("ping -c 3 -W 2 $vm1_ip 2>&1");
                $ping_ok = strpos($ping_output, 'bytes from') !== false;
            ?>
            <div class="info-grid" style="margin-bottom: 15px;">
                <div class="info-item">
                    <div class="label">Ping ICMP</div>
                    <div class="value" style="color: <?php echo $ping_ok ? '#98FB98' : '#FF6B6B'; ?>">
                        <?php echo $ping_ok ? 'EXITOSO' : 'FALLIDO'; ?>
                    </div>
                </div>
                <?php
                    $http_code = trim(shell_exec("curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 http://$vm1_ip 2>/dev/null"));
                    $http_ok = $http_code === '200';
                ?>
                <div class="info-item">
                    <div class="label">HTTP (Puerto 80)</div>
                    <div class="value" style="color: <?php echo $http_ok ? '#98FB98' : '#FF6B6B'; ?>">
                        <?php echo $http_ok ? "EXITOSO (HTTP $http_code)" : "FALLIDO (HTTP $http_code)"; ?>
                    </div>
                </div>
            </div>
            <div class="network-diagram">
<strong>$ ping -c 3 <?php echo $vm1_ip; ?></strong>
<?php echo htmlspecialchars(trim($ping_output)); ?>
            </div>
        </div>

        <div class="footer">
            <p>Fecha: <?php echo date('d/m/Y H:i:s'); ?></p>
            <p style="margin-top: 10px;">Desarrollado por <strong>Jorge Sarricolea</strong></p>
            <p>Instituto Tecnológico de Mérida - Azure Lab</p>
        </div>
    </div>
</body>
</html>
