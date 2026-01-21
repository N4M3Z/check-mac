#!/bin/bash
# Source: drduh/macOS-Security-and-Privacy-Guide#dns
# Source: kristovatlas/osx-config-check (CHECK #42)

# Retrieve DNS servers
dns_server=$(
    networksetup -getdnsservers Wi-Fi 2>/dev/null | head -1
)

# Check if using known secure DNS
# Cloudflare: 1.1.1.1, 1.0.0.1,
# Google: 8.8.8.8, 8.8.4.4
is_secure=0
if [[ "$dns_server" =~ ^(1\.1\.1\.1|1\.0\.0\.1|9\.9\.9\.9|76\.76\.2\.0|8\.8\.8\.8|8\.8\.4\.4)$ ]]; then
    is_secure=1
fi

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_dns=$INFO

[[ $is_secure == 1 ]] && pass_dns=$OK

# Output (include dns_server for check.sh to display)
echo "dns_server:$dns_server"
echo "is_secure:$is_secure"
echo "pass_dns:$pass_dns"
