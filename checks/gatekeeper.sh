#!/bin/bash
# Source: https://support.apple.com/en-us/102445

# Retrieve value
gatekeeper_status=$(
    spctl --status 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_gatekeeper=$CRIT

[[ "$gatekeeper_status" == *"enabled"* ]] && pass_gatekeeper=$OK

# Output
echo "pass_gatekeeper:$pass_gatekeeper"
