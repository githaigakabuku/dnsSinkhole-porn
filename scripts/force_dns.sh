#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "=== Forcing System to use Local DNS Blocker ==="

# 1. Configure systemd-resolved to use 127.0.0.1
echo "Configuring /etc/systemd/resolved.conf..."
# Backup
cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak

# We need to set DNS=127.0.0.1 and Domains=~. (to route everything there)
# We also ensure DNSStubListener is NO because we have dnsmasq on port 53
cat <<EOF > /etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~.
#FallbackDNS=8.8.8.8
DNSStubListener=no
EOF

echo "Restarting systemd-resolved..."
systemctl restart systemd-resolved

# 2. Update /etc/resolv.conf symlink
# Sometimes it points to the "uplink" file which ignores our settings.
# We want it to point to the "stub" or just be a static file.
# Since we disabled the stub listener, we should manually point resolv.conf to 127.0.0.1
echo "Updating /etc/resolv.conf..."
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
# Lock it so NetworkManager doesn't overwrite it
chattr +i /etc/resolv.conf

echo "Restarting Network Manager (to be safe)..."
systemctl restart NetworkManager 2>/dev/null || true

echo "=== Verification ==="
echo "Current resolv.conf content:"
cat /etc/resolv.conf

echo "Testing blocking..."
if dig +short pornhub.com | grep "0.0.0.0"; then
    echo "[SUCCESS] pornhub.com is BLOCKED (0.0.0.0)"
else
    echo "[WARNING] pornhub.com is NOT blocked yet. You might need to reboot."
fi
