#!/bin/bash
# Source: kristovatlas/osx-config-check (CHECK #76-77)

# Retrieve values
disable_remote_content=$(
    defaults read ~/Library/Preferences/com.apple.mail-shared DisableURLLoading 2>/dev/null
)
junk_filter=$(
    defaults read ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail JunkMailBehavior 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_remote_content=$INFO
pass_junk_filter=$INFO

[[ "$disable_remote_content" == "1" ]] && pass_remote_content=$OK
[[ "$junk_filter" != "0" ]] && pass_junk_filter=$OK

# Output
echo "pass_remote_content:$pass_remote_content"
echo "pass_junk_filter:$pass_junk_filter"
