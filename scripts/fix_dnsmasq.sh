#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "=== Fixing DNSMasq Configuration ==="

# Backup original config if not already done
if [ ! -f /etc/dnsmasq.conf.bak ]; then
    echo "Backing up original dnsmasq.conf..."
    mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi

# Create a clean, minimal dnsmasq.conf
# We only need to tell it to load configs from /etc/dnsmasq.d/
echo "Creating minimal dnsmasq.conf..."
cat <<EOF > /etc/dnsmasq.conf
# Minimal dnsmasq config for Porn Blocker
conf-dir=/etc/dnsmasq.d/,*.conf
EOF

echo "Restarting DNSMasq..."
systemctl restart dnsmasq

if systemctl is-active --quiet dnsmasq; then
    echo "DNSMasq is now RUNNING!"
else
    echo "DNSMasq still failed. Checking logs..."
    journalctl -u dnsmasq --no-pager | tail -n 20
fi

echo "=== Fix Complete ==="
