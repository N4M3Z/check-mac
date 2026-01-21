#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/firewall.sh
# Source: kristovatlas/osx-config-check (CHECK #16-17)

# Retrieve values
firewall_state=$(
    /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null
)
stealth_mode=$(
    /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null
)
allow_signed=$(
    /usr/libexec/ApplicationFirewall/socketfilterfw --getallowsigned 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_firewall_enabled=$CRIT
pass_stealth_mode=$WARN
pass_auto_whitelist=$WARN

[[ "$firewall_state" == *"Firewall is enabled"* ]] && pass_firewall_enabled=$OK
[[ "$stealth_mode" == *"stealth mode is on"* ]] && pass_stealth_mode=$OK
[[ "$allow_signed" == *"built-in"*"DISABLED"* ]] && pass_auto_whitelist=$OK

# Output
echo "pass_firewall_enabled:$pass_firewall_enabled"
echo "pass_stealth_mode:$pass_stealth_mode"
echo "pass_auto_whitelist:$pass_auto_whitelist"
