#!/bin/bash

echo "=== Testing Porn Blocker ==="

echo "1. Testing Local Development (Should be ALLOWED)..."
# Just checking if we can resolve localhost
if ping -c 1 localhost &> /dev/null; then
    echo "[PASS] localhost is resolvable"
else
    echo "[FAIL] localhost is NOT resolvable"
fi

echo "2. Testing Porn Domain Blocking (DNS Layer)..."
# Pick a domain from the list, e.g., pornhub.com
# It should resolve to 0.0.0.0
IP=$(dig +short pornhub.com @127.0.0.1)
if [ "$IP" == "0.0.0.0" ]; then
    echo "[PASS] pornhub.com resolves to 0.0.0.0"
else
    echo "[FAIL] pornhub.com resolves to $IP (Should be 0.0.0.0)"
fi

echo "3. Testing SafeSearch (Google)..."
# Google should resolve to the VIP
IP=$(dig +short www.google.com @127.0.0.1)
if [ "$IP" == "216.239.38.120" ]; then
    echo "[PASS] www.google.com resolves to SafeSearch VIP"
else
    echo "[FAIL] www.google.com resolves to $IP"
fi

echo "=== Test Complete ==="
