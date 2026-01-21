#!/bin/bash
# Source: kristovatlas/osx-config-check

# Retrieve value
bluetooth_state=$(
    system_profiler SPBluetoothDataType 2>/dev/null | grep -i "State:" | awk '{print $2}'
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_bluetooth=$INFO

[[ "$bluetooth_state" == "Off" ]] && pass_bluetooth=$OK

# Output
echo "pass_bluetooth:$pass_bluetooth"
