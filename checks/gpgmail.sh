#!/bin/bash
# Detect secure email apps

# Retrieve values
email_apps=""
[[ -d "/Library/Mail/Bundles/GPGMail.mailbundle" || -d "$HOME/Library/Mail/Bundles/GPGMail.mailbundle" ]] && email_apps="${email_apps}GPGMail, "
[[ -d "/Applications/Proton Mail.app" ]] && email_apps="${email_apps}Proton Mail, "
email_apps="${email_apps%, }"

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_email_apps=$WARN
[[ -n "$email_apps" ]] && pass_email_apps=$OK

# Output
echo "email_apps:$email_apps"
echo "pass_email_apps:$pass_email_apps"
