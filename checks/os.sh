#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/os.sh

# Retrieve values
product_name=$(sw_vers -productName 2>/dev/null)
product_version=$(sw_vers -productVersion 2>/dev/null)
build_version=$(sw_vers -buildVersion 2>/dev/null)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_os=$INFO

# Output (include values for check.sh to display)
echo "product_name:$product_name"
echo "product_version:$product_version"
echo "build_version:$build_version"
echo "pass_os:$pass_os"
