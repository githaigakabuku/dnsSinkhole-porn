#!/bin/bash

# Define variables
SOURCE_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
TEMP_FILE=$(mktemp)
# Determine the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# The lists directory is one level up from scripts
LISTS_DIR="$SCRIPT_DIR/../lists"

# Ensure lists directory exists
mkdir -p "$LISTS_DIR"

echo "Downloading blocklist from $SOURCE_URL..."
if curl -s "$SOURCE_URL" -o "$TEMP_FILE"; then
    echo "Download successful. Processing files..."

    # Create dnsmasq.blocklist
    # Format: address=/domain/0.0.0.0
    # Logic: Look for lines starting with 0.0.0.0, ignore 0.0.0.0 0.0.0.0, extract domain ($2)
    awk '$1 == "0.0.0.0" && $2 != "0.0.0.0" { print "address=/" $2 "/0.0.0.0" }' "$TEMP_FILE" > "$LISTS_DIR/dnsmasq.blocklist"
    echo "Created $LISTS_DIR/dnsmasq.blocklist"

    # Create squid.blocklist
    # Format: domain (one per line)
    # Logic: Same as above but just the domain. Remove leading . if present to ensure clean domain list
    awk '$1 == "0.0.0.0" && $2 != "0.0.0.0" { print $2 }' "$TEMP_FILE" > "$LISTS_DIR/squid.blocklist"
    echo "Created $LISTS_DIR/squid.blocklist"

    # Cleanup
    rm "$TEMP_FILE"
    echo "Done."
else
    echo "Failed to download blocklist."
    rm "$TEMP_FILE"
    exit 1
fi
