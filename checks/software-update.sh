#!/bin/bash
# Source: derflounder.wordpress.com/2025/12/17/reading-ddm-managed-apple-software-update-settings

DDM="/var/db/softwareupdate/SoftwareUpdateDDMStatePersistence"

# Retrieve values - try DDM first (macOS 15+), fall back to old plist
if [ -f "${DDM}.plist" ]; then
    auto_check=$(
        defaults read "$DDM" SUCorePersistedStatePolicyFields 2>/dev/null |
        grep enableGlobalNotifications | awk '{print $3}' | tr -d ';'
    )
    auto_download=$(
        defaults read "$DDM" SUCorePersistedStatePolicyFields 2>/dev/null |
        grep automaticallyDownload | awk '{print $3}' | tr -d ';'
    )
    auto_install_os=$(
        defaults read "$DDM" SUCorePersistedStatePolicyFields 2>/dev/null |
        grep automaticallyInstallOSUpdates | awk '{print $3}' | tr -d ';'
    )
    auto_install_security=$(
        defaults read "$DDM" SUCorePersistedStatePolicyFields 2>/dev/null |
        grep automaticallyInstallSystemAndSecurityUpdates | awk '{print $3}' | tr -d ';'
    )
else
    # Old plist
    [[ "$(softwareupdate --schedule 2>/dev/null)" == *"turned on"* ]] && auto_check=1 || auto_check=0
    auto_download=$(
        defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload 2>/dev/null
    )
    auto_install_os=$(
        defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates 2>/dev/null
    )
    auto_install_security=$(
        defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall 2>/dev/null
    )
fi

# Apply defaults
auto_check=${auto_check:-0}
auto_download=${auto_download:-0}
auto_install_os=${auto_install_os:-0}
auto_install_security=${auto_install_security:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_auto_check=$CRIT
pass_auto_download=$INFO
pass_critical_updates=$CRIT
pass_macos_updates=$INFO

[[ "$auto_check" == "1" ]] && pass_auto_check=$OK
[[ "$auto_download" == "1" ]] && pass_auto_download=$OK
[[ "$auto_install_security" == "1" ]] && pass_critical_updates=$OK
[[ "$auto_install_os" == "1" ]] && pass_macos_updates=$OK

# Output
echo "pass_auto_check:$pass_auto_check"
echo "pass_auto_download:$pass_auto_download"
echo "pass_critical_updates:$pass_critical_updates"
echo "pass_macos_updates:$pass_macos_updates"
