#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/hardware.sh

# Retrieve values
hardware_info=$(
    system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Model Identifier|Serial Number/{print $2}'
)
model=$(echo "$hardware_info" | sed -n '1p')
serial=$(echo "$hardware_info" | sed -n '2p')

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_hardware=$INFO

# Output (include values for check.sh to display)
echo "model:$model"
echo "serial:$serial"
echo "pass_hardware:$pass_hardware"
