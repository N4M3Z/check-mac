#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/gpgmail.sh" 2>/dev/null)
# Should return 2 lines: email_apps and pass_email_apps
[[ $(echo "$result" | wc -l) -ge 2 ]] && echo "PASS" || echo "FAIL"
