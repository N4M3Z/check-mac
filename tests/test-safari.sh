#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/safari.sh" 2>/dev/null)
# Should return 13 lines (5 basic + 8 advanced)
[[ $(echo "$result" | wc -l) -ge 13 ]] && echo "PASS" || echo "FAIL"
