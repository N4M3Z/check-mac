#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/firewall.sh" 2>/dev/null)
# Should contain firewall state, stealth mode, and allowsigned
echo "$result" | grep -qi "firewall" && echo "$result" | grep -qi "stealth" && echo "PASS" || echo "FAIL"
