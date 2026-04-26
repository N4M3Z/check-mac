#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#terminal

# Retrieve value
secure_keyboard=$(
    defaults read com.apple.Terminal SecureKeyboardEntry 2>/dev/null
)

# Test logic (Nagios exit codes plus UNKNOWN; see ADR-0003)
OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

pass_secure_keyboard=$UNKNOWN
[[ "$secure_keyboard" == "1" ]] && pass_secure_keyboard=$OK
[[ "$secure_keyboard" == "0" ]] && pass_secure_keyboard=$WARN

# Output
echo "pass_secure_keyboard:$pass_secure_keyboard"
