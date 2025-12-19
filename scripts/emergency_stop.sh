#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "!!! EMERGENCY STOP !!!"
echo "Unlocking files..."
chattr -i /etc/porn-blocker/dnsmasq.blocklist
chattr -i /etc/porn-blocker/squid.blocklist
chattr -i /etc/dnsmasq.d/porn-blocker.conf
chattr -i /etc/squid/squid.conf

echo "Stopping services..."
systemctl stop porn-blocker-watchdog
systemctl disable porn-blocker-watchdog
systemctl stop dnsmasq
systemctl stop squid

echo "Restoring configurations..."
if [ -f /etc/squid/squid.conf.bak ]; then
    cp /etc/squid/squid.conf.bak /etc/squid/squid.conf
fi
rm /etc/dnsmasq.d/porn-blocker.conf

echo "Restarting services to clean state..."
systemctl restart dnsmasq
systemctl restart squid

echo "Done. System restored."
