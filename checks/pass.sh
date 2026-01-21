#!/bin/bash
# Password managers

# Retrieve values
pass_managers=""
command -v pass >/dev/null 2>&1 && pass_managers="${pass_managers}pass, "
[[ -d "/Applications/Proton Pass.app" ]] && pass_managers="${pass_managers}Proton Pass, "
[[ -d "/Applications/1Password.app" ]] && pass_managers="${pass_managers}1Password, "
[[ -d "/Applications/Bitwarden.app" ]] && pass_managers="${pass_managers}Bitwarden, "

# Remove trailing comma and space
pass_managers="${pass_managers%, }"

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_pass=$WARN
[[ -n "$pass_managers" ]] && pass_pass=$OK

# Output
echo "pass_managers:$pass_managers"
echo "pass_pass:$pass_pass"
