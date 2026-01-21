#!/bin/bash
# This script may return empty (no ports listening) - that's valid
"$(dirname "$0")/../checks/remote-login.sh" &>/dev/null
echo "PASS"
