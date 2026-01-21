#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/dns.sh" 2>/dev/null)
# Should return DNS servers or "There aren't any DNS Servers set"
[[ -n "$result" ]] && echo "PASS" || echo "FAIL"
