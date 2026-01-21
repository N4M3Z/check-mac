#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#users

# Retrieve values
show_full_name=$(
    defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME 2>/dev/null
)
disable_console=$(
    defaults read /Library/Preferences/com.apple.loginwindow DisableConsoleAccess 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_show_full_name=$INFO
pass_disable_console=$WARN

[[ "$show_full_name" == "1" ]] && pass_show_full_name=$OK
[[ "$disable_console" == "1" ]] && pass_disable_console=$OK

# Output
echo "pass_show_full_name:$pass_show_full_name"
echo "pass_disable_console:$pass_disable_console"
