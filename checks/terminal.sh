#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#terminal

# Retrieve value
secure_keyboard=$(
    defaults read com.apple.Terminal SecureKeyboardEntry 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_secure_keyboard=$INFO

[[ "$secure_keyboard" == "1" ]] && pass_secure_keyboard=$OK

# Output
echo "pass_secure_keyboard:$pass_secure_keyboard"
