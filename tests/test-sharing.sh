#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/sharing.sh" 2>/dev/null)
# Should return 3 lines
[[ $(echo "$result" | wc -l) -ge 3 ]] && echo "PASS" || echo "FAIL"
