#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/remote-management.sh" 2>/dev/null)
[[ "$result" =~ "ard:" && "$result" =~ "ae:" && "$result" =~ "womp:" ]] && echo "PASS" || echo "FAIL"
