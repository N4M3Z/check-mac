#!/bin/bash
# Source: https://support.apple.com/en-us/102445

XPROTECT_PLIST="/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist"

# Retrieve version
version=$(
    defaults read "$XPROTECT_PLIST" CFBundleShortVersionString 2>/dev/null
)

# Retrieve age - try xprotect command first (macOS 15+), fall back to file mtime
current_epoch=$(date "+%s")
install_epoch=""

if command -v xprotect >/dev/null 2>&1; then
    install_date=$(
        xprotect version 2>/dev/null | awk '{print $4, $5, $6}'
    )
    [[ -n "$install_date" ]] && install_epoch=$(
        date -j -f "%Y-%m-%d %H:%M:%S %z" "$install_date" "+%s" 2>/dev/null
    )
fi

# Fall back to file modification time
[[ -z "$install_epoch" && -f "$XPROTECT_PLIST" ]] && install_epoch=$(
    stat -f "%m" "$XPROTECT_PLIST" 2>/dev/null
)

# Calculate age
[[ -n "$install_epoch" ]] && days_old=$(( (current_epoch - install_epoch) / 86400 ))

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_xprotect=$WARN

if [[ -z "$version" ]]; then
    pass_xprotect=$CRIT
elif [[ -z "$days_old" ]]; then
    pass_xprotect=$WARN
elif [[ $days_old -lt 90 ]]; then
    pass_xprotect=$OK
fi

# Output (include version and age for check.sh to display)
echo "version:${version:-unknown}"
echo "days_old:${days_old:-unknown}"
echo "pass_xprotect:$pass_xprotect"
