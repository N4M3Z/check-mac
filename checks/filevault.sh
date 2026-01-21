#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/file-vault.sh
# Source: kristovatlas/osx-config-check (CHECK #38-39)

# Retrieve values
filevault_enabled=$(
    fdesetup isactive 2>/dev/null
)
hibernate_mode=$(
    pmset -g 2>/dev/null | grep -i "hibernatemode" | awk '{print $2}'
)

# Apply defaults
hibernate_mode=${hibernate_mode:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_filevault_enabled=$CRIT
pass_hibernate_mode=$INFO

[[ "$filevault_enabled" == "true" ]] && pass_filevault_enabled=$OK
[[ "$hibernate_mode"    == "25"   ]] && pass_hibernate_mode=$OK

# Output (include hibernatemode for display)
echo "hibernatemode:$hibernate_mode"
echo "pass_filevault_enabled:$pass_filevault_enabled"
echo "pass_hibernate_mode:$pass_hibernate_mode"
