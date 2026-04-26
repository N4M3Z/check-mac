#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#users
#
# autoLoginUser is unset when autologin is off, but DDM-managed corporate Macs
# may enforce policy outside the legacy plist domain. Empty surfaces as UNKNOWN
# per ADR-0003 rather than silent OK; only one flip is needed because the value
# is a username (or absent), not a 0/1 toggle.

# Retrieve value
autologin_user=$(
    defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null
)

# Test logic (Nagios exit codes plus UNKNOWN; see ADR-0003)
OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

pass_autologin=$UNKNOWN
[[ -n "$autologin_user" ]] && pass_autologin=$CRIT

# Output
echo "pass_autologin:$pass_autologin"
