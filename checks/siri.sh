#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#siri

# Retrieve value
siri_enabled=$(
    defaults read com.apple.assistant.support "Assistant Enabled" 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_siri=$INFO

[[ "$siri_enabled" == "0" ]] && pass_siri=$OK

# Output
echo "pass_siri:$pass_siri"
