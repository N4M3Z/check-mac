#!/bin/bash
# Source: kristovatlas/osx-config-check (CHECK #30-31, #33)

# Retrieve values
ard_running=$(
    pgrep -x "ARDAgent" >/dev/null 2>&1 && echo "1" || echo "0"
)
ae_running=$(
    launchctl list 2>/dev/null | grep -q "com.apple.AEServer" && echo "1" || echo "0"
)
womp_enabled=$(
    pmset -g 2>/dev/null | grep -i "womp" | awk '{print $2}'
)

# Apply defaults
womp_enabled=${womp_enabled:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_ard=$OK
pass_apple_events=$OK
pass_wake_on_network=$INFO

[[ "$ard_running" == "1" ]] && pass_ard=$WARN
[[ "$ae_running" == "1" ]] && pass_apple_events=$WARN
[[ "$womp_enabled" == "1" ]] && pass_wake_on_network=$INFO || pass_wake_on_network=$OK

# Output
echo "pass_ard:$pass_ard"
echo "pass_apple_events:$pass_apple_events"
echo "pass_wake_on_network:$pass_wake_on_network"
