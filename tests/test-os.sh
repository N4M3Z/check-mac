#!/bin/bash
output=$("$(dirname "$0")/../checks/os.sh" 2>/dev/null)
[[ $(echo "$output" | wc -l) -eq 3 ]] && echo "PASS" || echo "FAIL"
