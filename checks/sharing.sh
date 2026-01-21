#!/bin/bash
# Source: kristovatlas/osx-config-check (CHECK #26-29, #32)

# Retrieve values
airdrop_disabled=$(
    defaults read com.apple.NetworkBrowser DisableAirDrop 2>/dev/null
)
printer_sharing=$(
    cupsctl 2>/dev/null | grep -q "_share_printers=1" && echo "1" || echo "0"
)
internet_sharing=$(
    launchctl list 2>/dev/null | grep -q com.apple.NetworkSharing && echo "1" || echo "0"
)

# Apply defaults
airdrop_disabled=${airdrop_disabled:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_airdrop=$INFO
pass_printer_sharing=$OK
pass_internet_sharing=$OK

[[ "$airdrop_disabled" == "1" ]] && pass_airdrop=$OK
[[ "$printer_sharing" == "1" ]] && pass_printer_sharing=$WARN
[[ "$internet_sharing" == "1" ]] && pass_internet_sharing=$WARN

# Output
echo "pass_airdrop:$pass_airdrop"
echo "pass_printer_sharing:$pass_printer_sharing"
echo "pass_internet_sharing:$pass_internet_sharing"
