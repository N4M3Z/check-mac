#!/bin/bash
output=$("$(dirname "$0")/../checks/sip.sh" 2>/dev/null)
echo "$output" | grep -qi "status" && echo "PASS" || echo "FAIL"
