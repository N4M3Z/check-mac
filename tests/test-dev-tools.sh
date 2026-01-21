#!/bin/bash
DIR="$(dirname "$0")/../checks"
result=$("$DIR/dev-tools.sh" 2>/dev/null)
# Should return 3 lines with git:, curl:, openssl:
[[ "$result" =~ "git:" && "$result" =~ "curl:" && "$result" =~ "openssl:" ]] && echo "PASS" || echo "FAIL"
