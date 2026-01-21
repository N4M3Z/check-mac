#!/bin/bash
# Source: kristovatlas/osx-config-check (CHECK #1, #2, #13)

# Retrieve values
brew_installed=$(
    command -v brew >/dev/null 2>&1 && echo "1" || echo "0"
)
brew_path_first=0
IFS=':' read -ra path_entries <<< "$PATH"
for i in "${!path_entries[@]}"; do
    if [[ $i -lt 5 && ("${path_entries[$i]}" == "/usr/local/bin" || "${path_entries[$i]}" == "/opt/homebrew/bin") ]]; then
        brew_path_first=1
        break
    fi
done
brew_analytics_state=$(
    brew analytics state 2>/dev/null
)
brew_analytics=$(
    [[ "$brew_analytics_state" == *"disabled"* ]] && echo "0" || echo "1"
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_homebrew=$INFO
pass_homebrew_path=$INFO
pass_homebrew_analytics=$INFO

[[ "$brew_installed" == "1" ]] && pass_homebrew=$OK || pass_homebrew=$INFO
[[ "$brew_path_first" == "1" ]] && pass_homebrew_path=$OK || pass_homebrew_path=$INFO
[[ "$brew_analytics" == "0" ]] && pass_homebrew_analytics=$OK || pass_homebrew_analytics=$WARN

# Output
echo "brew_installed:$brew_installed"
echo "pass_homebrew:$pass_homebrew"
echo "pass_homebrew_path:$pass_homebrew_path"
echo "pass_homebrew_analytics:$pass_homebrew_analytics"
