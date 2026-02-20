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
    all|both)
        echo "=== Installing LAMP on both VMs ==="
        "$0" 1
        echo ""
        "$0" 2
        exit 0
        ;;
    *)
        echo "Usage: $0 [1|2|all]"
        echo "  1, vm1  - Install on VM1 (default)"
        echo "  2, vm2  - Install on VM2"
        echo "  all     - Install on both VMs"
        exit 1
        ;;
esac

echo "=== Installing Apache + PHP on $TARGET_NAME ==="
echo ""

sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "$VM_USER@$TARGET_IP" 'bash -s' 2>/dev/null << 'EOF'

# Check if Apache is installed
if systemctl is-active --quiet apache2; then
    echo "Apache: Already installed"
else
    echo "Apache: Installing..."
    sudo apt update -qq
    sudo apt install -y apache2 > /dev/null 2>&1
    echo "Apache: Installed"
fi

# Check if PHP is installed
if php -v > /dev/null 2>&1; then
    echo "PHP: Already installed ($(php -v | head -1 | awk '{print $2}'))"
else
    echo "PHP: Installing..."
    sudo apt install -y php libapache2-mod-php php-mysql > /dev/null 2>&1
    sudo systemctl restart apache2
    echo "PHP: Installed"
fi

# Create PHP welcome page
echo "Creating welcome page..."
sudo tee /var/www/html/index.php > /dev/null << 'PHPCODE'
<!DOCTYPE html>
<html>
<head>
    <title>Azure VM - PHP</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .container { text-align: center; background: rgba(255,255,255,0.1); padding: 40px; border-radius: 10px; }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .info { background: rgba(0,0,0,0.2); padding: 20px; border-radius: 5px; margin-top: 20px; text-align: left; }
        .info p { margin: 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Azure VM</h1>
        <p>PHP is running successfully!</p>
        <div class="info">
            <p><strong>Hostname:</strong> <?php echo gethostname(); ?></p>
            <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
            <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
            <p><strong>Date:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
    </div>
</body>
</html>
PHPCODE

# Remove default index.html if exists
sudo rm -f /var/www/html/index.html

echo ""
echo "=== DONE ==="
echo "Apache: $(systemctl is-active apache2)"
echo "PHP: $(php -v 2>/dev/null | head -1 | awk '{print $2}')"

EOF

echo ""
echo "View at: http://$TARGET_IP"
