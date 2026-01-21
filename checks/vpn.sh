#!/bin/bash
# VPN applications

# Retrieve values
vpn_apps=""
[[ -d "/Applications/ProtonVPN.app" ]] && vpn_apps="${vpn_apps}ProtonVPN, "
[[ -d "/Applications/Tunnelblick.app" ]] && vpn_apps="${vpn_apps}Tunnelblick, "
[[ -d "/Applications/Viscosity.app" ]] && vpn_apps="${vpn_apps}Viscosity, "

# Remove trailing comma and space
vpn_apps="${vpn_apps%, }"

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_vpn=$WARN
[[ -n "$vpn_apps" ]] && pass_vpn=$OK

# Output
echo "vpn_apps:$vpn_apps"
echo "pass_vpn:$pass_vpn"
