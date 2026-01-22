# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# check-mac

macOS security health check scripts.

## Structure

```
check-mac/
├── check.sh              # Main script - orchestrates all checks
├── lib/
│   ├── style.sh          # Colors, symbols, status strings, Nagios codes
│   └── helpers.sh        # Helper functions (run, key, check, pass, fail, warn, info)
└── checks/               # Independent check scripts
    ├── filevault.sh      # Disk encryption
    ├── firewall.sh       # Firewall settings
    ├── pass.sh           # Password managers
    ├── vpn.sh            # VPN applications
    └── ...               # etc.

```

## Commands

```bash
# Run all checks
./check.sh

# Run individual check script
./checks/filevault.sh

# Make new check executable
chmod +x checks/new.sh
```

## Architecture

The codebase follows a separation of concerns design:

1. **Check scripts** (`checks/*.sh`) - Independent scripts that:
   - Retrieve system settings
   - Test against security best practices
   - Output `variable:value` pairs with Nagios exit codes
   - Can be executed independently for testing

2. **Orchestrator** (`check.sh`) - Runs all checks and formats output:
   - Sources library files (`lib/style.sh`, `lib/helpers.sh`)
   - Calls check scripts via `run()` helper
   - Extracts results via `key()` helper
   - Displays formatted results via `check()`, `pass()`, `fail()`, `warn()`, `info()`

3. **Libraries** (`lib/`) - Shared definitions:
   - `style.sh`: Colors, symbols, Nagios codes, status strings
   - `helpers.sh`: Functions for running checks and formatting output

**Data flow:**
```
check script → pass_variable:code → check.sh → formatted output
  (test)         (0/1/2/3)            (display)
```

**Nagios exit codes:**
- `0` = OK (green ✓) - security setting is optimal
- `1` = WARNING (yellow !) - recommended to fix
- `2` = CRITICAL (red ✗) - security issue
- `3` = INFO (blue ℹ) - informational, no action needed

## Patterns

### Check Script Pattern (checks/$name.sh)

All check scripts follow this exact pattern:

```bash
#!/bin/bash
# Source: URL

# Retrieve values
setting=$(
    command 2>/dev/null
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

**Key principles:**
- Scripts are independently executable
- Use multi-line command substitution for readability
- Set default severity first, then test and update
- Output `pass_variable:code` format
- Include display values when needed (e.g., version numbers)

### Orchestrator Pattern (check.sh)

```bash
data=$(run filevault)
check "$(key pass_filevault_enabled)" "FileVault" "$ENABLED" "$DISABLED"
```

## Pattern Matching

Use bash built-ins instead of `echo | grep`:

```bash
# Good - bash built-in
[[ "$status" == *"enabled"* ]]
[[ "$ports" =~ \.22[[:space:]] ]]
[[ "$groups" == *admin* ]]

# Bad - subprocess spawn
echo "$status" | grep -q "enabled"
```

## macOS Version Handling

Check for newer commands first, fall back to older:

```bash
if command -v new_command >/dev/null 2>&1; then
    result=$(new_command 2>/dev/null)
else
    result=$(old_command 2>/dev/null)
fi
```

For more detailed pattern examples see [PATTERNS.md](PATTERNS.md)

## Common Pitfalls

1. Not quoting command substitutions: `check "$(key pass_check)"`
2. Not setting default severity before testing
3. Hardcoding strings instead of using variables from `lib/style.sh`
4. Using `echo | grep` instead of bash pattern matching
5. Not outputting display values when needed

## Shell Best Practices

- Always quote variables: `"$variable"`
- Use `[[ ]]` for tests, not `[ ]`
- Suppress expected errors: `2>/dev/null`
- Use multi-line command substitution for readability
- Follow exact spacing/structure from existing checks

## Adding New Checks

1. Create `checks/$name.sh` following the pattern
2. Make executable: `chmod +x checks/$name.sh`
3. Test independently: `./checks/$name.sh`
4. Add to `check.sh` orchestrator using `check "$(key pass_name)"` pattern
5. Use status string variables from `lib/style.sh` (e.g., `$ENABLED`, `$DISABLED`)
