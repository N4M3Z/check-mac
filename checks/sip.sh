#!/bin/bash
# Source: https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection

# Retrieve value
sip_status=$(
    csrutil status 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_sip=$CRIT

[[ "$sip_status" == *"enabled"* ]] && pass_sip=$OK

# Output
echo "pass_sip:$pass_sip"
