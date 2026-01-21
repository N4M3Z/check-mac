#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/bluetooth.sh" 2>/dev/null)
[[ "$result" == "On" || "$result" == "Off" ]] && echo "PASS" || echo "FAIL"
