#!/bin/bash
output=$("$(dirname "$0")/../checks/gatekeeper.sh" 2>/dev/null)
echo "$output" | grep -qi "enabled\|disabled" && echo "PASS" || echo "FAIL"
