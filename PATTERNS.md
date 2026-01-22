# Check Script Patterns

All check scripts follow the Nagios exit code pattern. Scripts are independently executable and output severity codes.

## Nagios Exit Codes

```bash
OK=0     # Pass - security setting is optimal
WARN=1   # Warning - recommended to fix
CRIT=2   # Critical - security issue
INFO=3   # Informational - no action needed
```

## Standard Pattern

**Template** (see `checks/filevault.sh`):

```bash
#!/bin/bash
# Source: URL

# Retrieve values
setting=$(
    defaults read com.example.plist Key 2>/dev/null
)

# Apply defaults
setting=${setting:-default}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_check=$CRIT
[[ "$setting" == "expected" ]] && pass_check=$OK

# Output
echo "pass_check:$pass_check"
```

**Structure:**
1. Retrieve values (multi-line for readability)
2. Apply defaults using `${var:-default}`
3. Define Nagios codes
4. Set default severity
5. Test and update severity
6. Output `pass_variable:code`

## Multiple Checks

From `checks/firewall.sh` - testing multiple settings:

```bash
#!/bin/bash
# Source: URL

# Retrieve values
firewall_enabled=$(
    defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null
)
stealth_mode=$(
    defaults read /Library/Preferences/com.apple.alf stealthenabled 2>/dev/null
)

# Apply defaults
firewall_enabled=${firewall_enabled:-0}
stealth_mode=${stealth_mode:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_firewall_enabled=$CRIT
pass_stealth_mode=$WARN

[[ "$firewall_enabled" != "0" ]] && pass_firewall_enabled=$OK
[[ "$stealth_mode" == "1" ]] && pass_stealth_mode=$OK

# Output
echo "pass_firewall_enabled:$pass_firewall_enabled"
echo "pass_stealth_mode:$pass_stealth_mode"
```

## With Display Values

From `checks/xprotect.sh` - output values for display:

```bash
# Retrieve version
version=$(
    defaults read /path/to/Info.plist CFBundleShortVersionString 2>/dev/null
)

# Test logic
OK=0; WARN=1; CRIT=2; INFO=3

pass_xprotect=$WARN

if [[ -z "$version" ]]; then
    pass_xprotect=$CRIT
elif [[ $days_old -lt 90 ]]; then
    pass_xprotect=$OK
fi

# Output (include version for display)
echo "version:${version:-unknown}"
echo "days_old:${days_old:-unknown}"
echo "pass_xprotect:$pass_xprotect"
```

## List Detection Pattern

From `checks/vpn.sh` - detect and list applications:

```bash
#!/bin/bash
# VPN applications

# Retrieve values
vpn_apps=""
[[ -d "/Applications/ProtonVPN.app" ]] && vpn_apps="${vpn_apps}ProtonVPN, "
[[ -d "/Applications/Tunnelblick.app" ]] && vpn_apps="${vpn_apps}Tunnelblick, "

# Remove trailing comma and space
vpn_apps="${vpn_apps%, }"

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_vpn=$WARN
[[ -n "$vpn_apps" ]] && pass_vpn=$OK

# Output
echo "vpn_apps:$vpn_apps"
echo "pass_vpn:$pass_vpn"
```

## Usage in check.sh

**Basic:**
```bash
data=$(run filevault)
check "$(key pass_filevault_enabled)" "FileVault" "$ENABLED" "$DISABLED"
```

**With display values:**
```bash
data=$(run xprotect)
xprotect_version=$(key version)
pass_xprotect=$(key pass_xprotect)
case "$pass_xprotect" in
    0) pass "XProtect" "v$xprotect_version" ;;
    1) warn "XProtect" "v$xprotect_version" ;;
    2) fail "XProtect" "$NOT_FOUND" ;;
esac
```

**With lists:**
```bash
data=$(run vpn)
vpn_apps=$(key vpn_apps)
if [[ -n "$vpn_apps" ]]; then
    check "$(key pass_vpn)" "VPN" "$vpn_apps" "$NOT_INSTALLED"
else
    warn "VPN" "$NOT_INSTALLED"
fi
```

## Pattern Matching

Use bash built-ins for substring/regex matching:

```bash
# Substring (case-sensitive)
[[ "$status" == *"enabled"* ]]

# Regex
[[ "$ports" =~ \.22[[:space:]] ]]
[[ "$dns" =~ ^(1\.1\.1\.1|8\.8\.8\.8)$ ]]

# Wildcard
[[ "$groups" == *admin* ]]
```

**Never use:**
```bash
echo "$var" | grep -q "pattern"  # Spawns subprocess
```

## Why These Patterns?

1. **Testability** - Scripts run independently: `./checks/filevault.sh`
2. **Separation** - Data + testing in check script, display in check.sh
3. **Common Standards** - Nagios exit codes used widely in DevOps
4. **Readability** - Clear severity levels with explicit constants
5. **Flexibility** - Check scripts evolve independently of check.sh

## Rules

1. Scripts must be independently executable
2. Output format: `variable:value` on separate lines
3. Always define: `OK=0; WARN=1; CRIT=2; INFO=3`
4. Set default severity before testing
5. Use multi-line command substitution for readability
6. Quote all command substitutions in check.sh
7. Follow estabilished spacing/structure
