#!/bin/bash
DIR="$(dirname "$0")/checks"

# Source lib files
source "$(dirname "$0")/lib/style.sh"
source "$(dirname "$0")/lib/helpers.sh"

issues=0

br
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           macOS Security Health Check                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
br

# System Info
echo "┌ System Information ────────────────────────────────────────┐"
data=$(run os)
product_name=$(key product_name)
product_version=$(key product_version)
build_version=$(key build_version)
info "OS" "$product_name $product_version ($build_version)"

data=$(run hardware)
model=$(key model)
serial=$(key serial)
info "Model" "$model"
info "Serial" "$serial"

data=$(run system)
architecture=$(key architecture)
hostname=$(key hostname)
info "Architecture" "$architecture"
info "Hostname" "$hostname"
br

# Disk Encryption
echo "┌ Disk Encryption ───────────────────────────────────────────┐"
data=$(run filevault)
check "$(key pass_filevault_enabled)"   "FileVault"           "$ENABLED"  "$DISABLED"
check "$(key pass_hibernate_mode)"      "Hibernate Mode"      "Secure (25)" "$(key hibernatemode)"
br

# Firewall
echo "┌ Firewall ──────────────────────────────────────────────────┐"
data=$(run firewall)
check "$(key pass_firewall_enabled)" "Firewall"      "$ENABLED"  "$DISABLED"
check "$(key pass_stealth_mode)"     "Stealth Mode"  "$ENABLED"  "$DISABLED"
check "$(key pass_auto_whitelist)"   "Auto-Whitelist" "$DISABLED" "$ENABLED"
br

# Remote Access
echo "┌ Remote Access ─────────────────────────────────────────────┐"
data=$(run remote-login)
check "$(key pass_ssh)"          "SSH (Port 22)"        "$NOT_LISTENING" "$LISTENING"
check "$(key pass_telnet)"       "Telnet (Port 23)"     "$NOT_LISTENING" "$LISTENING"
check "$(key pass_screen_share)" "ScreenShare (Port 5900)" "$NOT_LISTENING" "$LISTENING"
check "$(key pass_file_share)"   "FileShare (Port 445)" "$NOT_LISTENING" "$LISTENING"

data=$(run remote-management)
check "$(key pass_ard)"             "Remote Management" "$DISABLED" "$ENABLED"
check "$(key pass_apple_events)"    "Apple Events"      "$DISABLED" "$ENABLED"
check "$(key pass_wake_on_network)" "Wake on Network"   "$DISABLED" "$ENABLED"
br

# Software Updates
echo "┌ Software Updates ──────────────────────────────────────────┐"
data=$(run software-update)
check "$(key pass_auto_check)"      "Automatic Check"    "$ENABLED" "$DISABLED"
check "$(key pass_auto_download)"   "Automatic Download" "$ENABLED" "$DISABLED"
check "$(key pass_critical_updates)" "Critical Updates"   "$ENABLED" "$DISABLED"
check "$(key pass_macos_updates)"   "macOS Auto-Updates" "$ENABLED" "$DISABLED"
br

# System Protection
echo "┌ System Protection ─────────────────────────────────────────┐"
data=$(run sip)
check "$(key pass_sip)" "SIP" "$ENABLED" "$DISABLED"

data=$(run gatekeeper)
check "$(key pass_gatekeeper)" "Gatekeeper" "$ENABLED" "$DISABLED"

data=$(run xprotect)
xprotect_age=$(key days_old)
pass_xprotect=$(key pass_xprotect)
case "$pass_xprotect" in
    0) pass "XProtect" "${xprotect_age}d old" ;;
    1) warn "XProtect" "${xprotect_age}d old" ;;
    2) fail "XProtect" "$NOT_FOUND" ;;
    *) info "XProtect" "(age unknown)" ;;
esac
br

# Screen Lock
echo "┌ Screen Lock ───────────────────────────────────────────────┐"
data=$(run screen-lock)
check "$(key pass_password_on_wake)" "Password on Wake" "$YES" "$NO"

idle_time=$(key idle_time)
pass_screen_timeout=$(key pass_screen_timeout)
if [[ $idle_time =~ ^[0-9]+$ ]] && [[ $idle_time -gt 0 ]]; then
    check "$pass_screen_timeout" "Screen Timeout" "$((idle_time/60)) min" "$((idle_time/60)) min"
else
    info "Screen Timeout" "Not set"
fi
br

# Privacy
echo "┌ Privacy ───────────────────────────────────────────────────┐"
data=$(run siri)
check "$(key pass_siri)" "Siri" "$DISABLED" "$ENABLED"

data=$(run analytics)
check "$(key pass_analytics)" "Analytics" "$DISABLED" "$ENABLED"

data=$(run finder)
check "$(key pass_show_extensions)" "Show Extensions" "$YES" "$NO"

data=$(run terminal)
check "$(key pass_secure_keyboard)" "Secure Keyboard" "$ENABLED" "$DISABLED"
br

# Network
echo "┌ Network ───────────────────────────────────────────────────┐"
data=$(run dns)
dns_server=$(key dns_server)
is_secure=$(key is_secure)
pass_dns=$(key pass_dns)
if [[ "$dns_server" == "There aren't any DNS Servers set on Wi-Fi." ]]; then
    info "DNS" "DHCP default"
elif [[ $is_secure == 1 ]]; then
    check "$pass_dns" "DNS" "$dns_server ($SECURE)" "$dns_server"
else
    check "$pass_dns" "DNS" "$dns_server" "$dns_server"
fi

data=$(run bluetooth)
check "$(key pass_bluetooth)" "Bluetooth" "$OFF" "$ON"
br

# Sharing
echo "┌ Sharing ───────────────────────────────────────────────────┐"
data=$(run sharing)
check "$(key pass_airdrop)"          "AirDrop"         "$DISABLED" "$ENABLED"
check "$(key pass_printer_sharing)"  "Printer Sharing" "$DISABLED" "$ENABLED"
check "$(key pass_internet_sharing)" "Internet Sharing" "$DISABLED" "$ENABLED"
br

# User Security
echo "┌ User Security ─────────────────────────────────────────────┐"
data=$(run user-security)
username=$(key username)
user_groups=$(key user_groups)
info "User" "$username"
[[ "$user_groups" == *admin* ]] && info "Type" "Admin" || pass "Type" "Standard"

check "$(key pass_guest)" "Guest" "$DISABLED" "$ENABLED"

data=$(run autologin)
check "$(key pass_autologin)" "Auto Login" "$DISABLED" "$ENABLED"
br

# Developer Tools
echo "┌ Developer Tools ───────────────────────────────────────────┐"
data=$(run homebrew)
brew_installed=$(key brew_installed)
if [[ $brew_installed == 1 ]]; then
    check "$(key pass_homebrew)"           "Homebrew"       "$INSTALLED" "$NOT_INSTALLED"
    check "$(key pass_homebrew_path)"      "Homebrew PATH"  "$PREFERRED" "$NOT_PREFERRED"
    check "$(key pass_homebrew_analytics)" "Brew Analytics" "$DISABLED"  "$ENABLED"
else
    info "Homebrew" "$NOT_INSTALLED"
fi

data=$(run dev-tools)
git_version=$(key git_version)
curl_version=$(key curl_version)
openssl_version=$(key openssl_version)
pass_git=$(key pass_git)
pass_curl=$(key pass_curl)
pass_openssl=$(key pass_openssl)

[[ $git_version == none ]] && info "Git" "$NOT_INSTALLED" || check "$pass_git" "Git" "v$git_version" "v$git_version (outdated)"
[[ $curl_version == none ]] && info "Curl" "$NOT_INSTALLED" || check "$pass_curl" "Curl" "v$curl_version" "v$curl_version (outdated)"
[[ $openssl_version == none ]] && info "OpenSSL" "$NOT_INSTALLED" || check "$pass_openssl" "OpenSSL" "v$openssl_version" "v$openssl_version (outdated)"
br

# Email Apps
echo "┌ Email Apps ────────────────────────────────────────────────┐"
data=$(run gpgmail)
email_apps=$(key email_apps)
if [[ -n "$email_apps" ]]; then
    check "$(key pass_email_apps)" "Email Apps" "$email_apps" "$NOT_INSTALLED"
else
    warn "Email Apps" "$NOT_INSTALLED"
fi
br

# Password Managers
echo "┌ Password Managers ─────────────────────────────────────────┐"
data=$(run pass)
pass_managers=$(key pass_managers)
if [[ -n "$pass_managers" ]]; then
    check "$(key pass_pass)" "Password Managers" "$pass_managers" "$NOT_INSTALLED"
else
    warn "Password Managers" "$NOT_INSTALLED"
fi
br

# VPN
echo "┌ VPN ───────────────────────────────────────────────────────┐"
data=$(run vpn)
vpn_apps=$(key vpn_apps)
if [[ -n "$vpn_apps" ]]; then
    check "$(key pass_vpn)" "VPN" "$vpn_apps" "$NOT_INSTALLED"
else
    warn "VPN" "$NOT_INSTALLED"
fi
br

# Configuration Profiles
echo "┌ Configuration Profiles ────────────────────────────────────┐"
data=$(run profiles)
mdm_enrolled=$(key mdm_enrolled)

[[ "$mdm_enrolled" == "1" ]] && output "$CHECK_MDM" "MDM" "$ENROLLED" || info "MDM" "$NOT_ENROLLED"
br

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
if (( issues == 0 )); then
    printf "║  %b  All checks passed!                                      ║\n" "$CHECK_PASS"
else
    printf "║  %b  Found %d issue(s)                                         ║\n" "$CHECK_WARN" "$issues"
fi
echo "╚══════════════════════════════════════════════════════════════╝"
br
printf "Legend: %b Pass  %b Fail  %b Warn  %b Info  %b MDM\n" "$CHECK_PASS" "$CHECK_FAIL" "$CHECK_WARN" "$CHECK_INFO" "$CHECK_MDM"
