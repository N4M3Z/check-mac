#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/xprotect.sh" 2>/dev/null)
[[ "$result" =~ ^[0-9]+$ ]] && echo "PASS" || echo "FAIL"
