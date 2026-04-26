#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#miscellaneous

# Retrieve value
finder_show_extensions=$(
    defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null
)

# Test logic (Nagios exit codes plus UNKNOWN; see ADR-0003)
OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

pass_finder_show_extensions=$UNKNOWN
[[ "$finder_show_extensions" == "1" ]] && pass_finder_show_extensions=$OK
[[ "$finder_show_extensions" == "0" ]] && pass_finder_show_extensions=$WARN

# Output
echo "pass_show_extensions:$pass_finder_show_extensions"
