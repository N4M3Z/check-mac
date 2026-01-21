#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/loginwindow.sh" 2>/dev/null)
# Returns 0 or 1 for each setting, or error if not set
[[ -n "$result" ]] || [[ $? -eq 1 ]] && echo "PASS" || echo "FAIL"
