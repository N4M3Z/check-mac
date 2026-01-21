#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#miscellaneous

# Retrieve value
finder_show_extensions=$(
    defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_finder_show_extensions=$INFO

[[ "$finder_show_extensions" == "1" ]] && pass_finder_show_extensions=$OK

# Output
echo "pass_show_extensions:$pass_finder_show_extensions"
