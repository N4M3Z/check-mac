#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#users

# Retrieve values
username=$(whoami 2>/dev/null)
user_groups=$(groups 2>/dev/null)
guest_enabled=$(
    defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_user=$INFO
pass_user_type=$INFO
pass_guest=$OK

[[ "$user_groups" == *admin* ]] && pass_user_type=$INFO || pass_user_type=$OK
[[ "$guest_enabled" == "1" ]] && pass_guest=$WARN

# Output (include username and groups for check.sh to display)
echo "username:$username"
echo "user_groups:$user_groups"
echo "guest_enabled:$guest_enabled"
echo "pass_user:$pass_user"
echo "pass_user_type:$pass_user_type"
echo "pass_guest:$pass_guest"
