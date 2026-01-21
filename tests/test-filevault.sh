#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/filevault.sh" 2>/dev/null)
# Should return 3 lines: true/false, destroyFVKey value, hibernate mode
[[ $(echo "$result" | wc -l) -ge 3 ]] && echo "PASS" || echo "FAIL"
