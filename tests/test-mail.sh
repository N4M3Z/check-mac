#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/mail.sh" 2>/dev/null)
# Should return 2 lines
[[ $(echo "$result" | wc -l) -ge 2 ]] && echo "PASS" || echo "FAIL"
