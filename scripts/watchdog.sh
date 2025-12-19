#!/bin/bash

# Simple watchdog to ensure services are running
while true; do
    if ! systemctl is-active --quiet dnsmasq; then
        echo "DNSMasq is down. Restarting..."
        systemctl restart dnsmasq
    fi
    
    if ! systemctl is-active --quiet squid; then
        echo "Squid is down. Restarting..."
        systemctl restart squid
    fi
    
    sleep 60
done
