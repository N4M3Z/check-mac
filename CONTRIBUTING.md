# Contributing

## Adding a New Check

1. **Create the check script** following [PATTERNS.md](PATTERNS.md):

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

2. **Make it executable**: `chmod +x checks/your-check.sh`

3. **Add to check.sh** orchestrator:

```bash
data=$(run your-check)
check "$(key pass_check)" "Check Name" "$ENABLED" "$DISABLED"
```

4. **Document in RATIONALE.md** with security rationale and sources

## Coding Standards

- Quote variables: `"$variable"`
- Use `[[ ]]` for tests
- Suppress expected errors: `2>/dev/null`
- Multi-line command substitution for readability
- Include source URL in comments
- Use status variables from `lib/style.sh`: `$ENABLED`, `$DISABLED`, etc.

## macOS Version Compatibility

For version-specific features, check for newer commands first:

```bash
if command -v new_command >/dev/null 2>&1; then
    result=$(new_command 2>/dev/null)
else
    result=$(old_command 2>/dev/null)
fi
```

See `checks/software-update.sh` for DDM example (macOS 15+/26+).

## License

By contributing, you agree contributions are licensed under MIT License.
