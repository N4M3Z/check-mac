#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#users

# Retrieve value
autologin_user=$(
    defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_autologin=$CRIT

[[ -z "$autologin_user" ]] && pass_autologin=$OK

# Output
echo "pass_autologin:$pass_autologin"
