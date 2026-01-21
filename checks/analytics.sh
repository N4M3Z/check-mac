#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#analytics

# Retrieve value
analytics_enabled=$(
    defaults read "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" AutoSubmit 2>/dev/null
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_analytics=$WARN

[[ "$analytics_enabled" == "0" ]] && pass_analytics=$OK

# Output
echo "pass_analytics:$pass_analytics"
