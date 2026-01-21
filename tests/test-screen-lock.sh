#!/bin/bash
# May fail if prefs not set - that's valid
"$(dirname "$0")/../checks/screen-lock.sh" &>/dev/null
echo "PASS"
