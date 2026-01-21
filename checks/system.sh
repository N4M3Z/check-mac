#!/bin/bash
# System information (architecture and hostname)

# Retrieve values
architecture=$(uname -m)
hostname=$(scutil --get ComputerName 2>/dev/null)

# Output (informational only)
echo "architecture:$architecture"
echo "hostname:$hostname"

# Exit codes (both informational)
pass_architecture=3
pass_hostname=3

echo "pass_architecture:$pass_architecture"
echo "pass_hostname:$pass_hostname"
