#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "=== Fixing Installation Issues ==="

echo "[1/3] Unmasking and fixing Squid..."
systemctl unmask squid
systemctl enable squid
systemctl restart squid

echo "[2/3] Fixing DNSMasq Port Conflict..."
# Stop systemd-resolved temporarily to free port 53
systemctl stop systemd-resolved

# Configure systemd-resolved to NOT bind to port 53
mkdir -p /etc/systemd/resolved.conf.d
cat <<EOF > /etc/systemd/resolved.conf.d/no-stub.conf
[Resolve]
DNSStubListener=no
EOF

# Restart systemd-resolved (it will now run without binding port 53)
systemctl restart systemd-resolved

# Now restart dnsmasq
systemctl restart dnsmasq

echo "[3/3] Verifying Services..."
if systemctl is-active --quiet squid; then
    echo "Squid is RUNNING."
else
    echo "Squid failed to start. Checking logs..."
    journalctl -u squid --no-pager | tail -n 10
fi

if systemctl is-active --quiet dnsmasq; then
    echo "DNSMasq is RUNNING."
else
    echo "DNSMasq failed to start. Checking logs..."
    journalctl -u dnsmasq --no-pager | tail -n 10
fi

echo "=== Fix Complete ==="
