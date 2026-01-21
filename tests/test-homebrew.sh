#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/homebrew.sh" 2>/dev/null)
[[ "$result" =~ "installed:" ]] && echo "PASS" || echo "FAIL"
