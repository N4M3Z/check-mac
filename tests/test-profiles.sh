#!/bin/bash
output=$("$(dirname "$0")/../checks/profiles.sh" 2>/dev/null)
[[ -n "$output" ]] && echo "PASS" || echo "FAIL"
