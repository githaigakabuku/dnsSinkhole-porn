# Robust Adult Content Blocker (Linux)

A production-grade, hard-to-disable adult content blocker designed for web developers. It blocks pornography at the DNS level while explicitly whitelisting local development environments (localhost, Docker, etc.).

## Features
- **DNS Sinkholing**: Blocks 100,000+ adult domains by resolving them to `0.0.0.0`.
- **SafeSearch Enforcement**: Forces Google, Bing, and DuckDuckGo to use "Safe Mode".
- **Developer Friendly**: Whitelists `localhost`, `127.0.0.1`, `10.x`, `192.168.x`, and `172.16.x` (Docker).
- **Tamper Resistant**: Uses `chattr +i` to lock config files and a watchdog service to auto-restart.

## Installation
```bash
# 1. Install and Lock Services
sudo ./scripts/install.sh

# 2. Force System to use Local DNS
sudo ./scripts/force_dns.sh
```

## Verification
```bash
./scripts/test.sh
```

## How to Disable (Emergency Only)
```bash
sudo ./scripts/emergency_stop.sh
```

## Architecture
1. **dnsmasq**: The DNS server that filters requests.
   - Config: `config/dnsmasq.conf`
   - List: `/etc/porn-blocker/dnsmasq.blocklist`
2. **squid**: Proxy server (currently secondary/optional).
   - Config: `config/squid.conf`
3. **Watchdog**: A systemd service that ensures the blocker is always running.
   - Script: `scripts/watchdog.sh`

## Maintenance
To update the blocklists:
```bash
# You must unlock files first
sudo chattr -i /etc/porn-blocker/*.blocklist
sudo ./scripts/update_blocklists.sh
sudo cp lists/*.blocklist /etc/porn-blocker/
sudo chattr +i /etc/porn-blocker/*.blocklist
sudo systemctl restart dnsmasq
```
