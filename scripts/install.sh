#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "=== Installing Porn Blocker System ==="

echo "[1/6] Installing dependencies..."
apt-get update
apt-get install -y dnsmasq squid curl

echo "[2/6] Creating system directories..."
mkdir -p /etc/porn-blocker

echo "[3/6] Generating blocklists..."
bash "$SCRIPT_DIR/update_blocklists.sh"
cp "$PROJECT_ROOT/lists/dnsmasq.blocklist" /etc/porn-blocker/
cp "$PROJECT_ROOT/lists/squid.blocklist" /etc/porn-blocker/

echo "[4/6] Installing configurations..."
# DNSMasq
cp "$PROJECT_ROOT/config/dnsmasq.conf" /etc/dnsmasq.d/porn-blocker.conf
# Disable systemd-resolved stub listener if it conflicts (common on Ubuntu)
if grep -q "#DNSStubListener=yes" /etc/systemd/resolved.conf; then
    sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved
fi

# Squid
if [ ! -f /etc/squid/squid.conf.bak ]; then
    cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
fi
cp "$PROJECT_ROOT/config/squid.conf" /etc/squid/squid.conf

echo "[5/6] Installing Watchdog Service..."
cp "$PROJECT_ROOT/scripts/watchdog.sh" /usr/local/bin/porn-blocker-watchdog.sh
chmod +x /usr/local/bin/porn-blocker-watchdog.sh
cp "$PROJECT_ROOT/systemd/porn-blocker-watchdog.service" /etc/systemd/system/
systemctl daemon-reload

echo "[6/6] Locking files (Immutable)..."
# Unlock first in case they are already locked
chattr -i /etc/porn-blocker/dnsmasq.blocklist 2>/dev/null
chattr -i /etc/porn-blocker/squid.blocklist 2>/dev/null
chattr -i /etc/dnsmasq.d/porn-blocker.conf 2>/dev/null
chattr -i /etc/squid/squid.conf 2>/dev/null

# Lock them
chattr +i /etc/porn-blocker/dnsmasq.blocklist
chattr +i /etc/porn-blocker/squid.blocklist
chattr +i /etc/dnsmasq.d/porn-blocker.conf
chattr +i /etc/squid/squid.conf

echo "Restarting services..."
systemctl restart dnsmasq
systemctl restart squid
systemctl enable dnsmasq
systemctl enable squid
systemctl enable porn-blocker-watchdog
systemctl start porn-blocker-watchdog

echo "=== Installation Complete ==="
echo "Please configure your system network settings to use 127.0.0.1 as DNS server."
echo "Or ensure your router/DHCP points to this machine."
