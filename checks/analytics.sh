#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#analytics

# Retrieve value
analytics_enabled=$(
    defaults read "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" AutoSubmit 2>/dev/null
)

# Test logic (Nagios exit codes plus UNKNOWN; see ADR-0003)
OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

pass_analytics=$UNKNOWN
[[ "$analytics_enabled" == "0" ]] && pass_analytics=$OK
[[ "$analytics_enabled" == "1" ]] && pass_analytics=$WARN

# Output
echo "pass_analytics:$pass_analytics"
