#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#siri

# Retrieve value
siri_enabled=$(
    defaults read com.apple.assistant.support "Assistant Enabled" 2>/dev/null
)

# Test logic (Nagios exit codes plus UNKNOWN; see ADR-0003)
OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

pass_siri=$UNKNOWN
[[ "$siri_enabled" == "0" ]] && pass_siri=$OK
[[ "$siri_enabled" == "1" ]] && pass_siri=$WARN

# Output
echo "pass_siri:$pass_siri"
