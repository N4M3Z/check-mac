# Contributing to check-mac

## Quick Start

1. Fork and clone
2. Create feature branch: `git checkout -b feature/your-check`
3. Make changes
4. Test with `./tests.sh` and `./check.sh`
5. Commit and open PR

## Adding a New Check

### 1. Read PATTERNS.md

Choose one of three patterns:
1. Single Value - Direct defaults read
2. Key-Value - Multiple related values
3. Line-Based - Sequential values

**Key principle:** Check scripts return raw data only. All logic in check.sh.

### 2. Create Check Script

```bash
touch checks/your-check.sh
chmod +x checks/your-check.sh
```

Example:
```bash
#!/bin/bash
# Source: https://github.com/drduh/macOS-Security-and-Privacy-Guide#section
defaults read com.example.plist KeyName
```

**Rules:**
- Return raw data only
- No `|| echo "default"` fallbacks
- No if/else logic
- Suppress expected errors with `2>/dev/null`
- Include source URL comment

### 3. Add to check.sh

```bash
echo "┌ Section ───────────────────────────────────────────────────┐"
data=$(run your-check)
[[ $(line 1) == "expected" ]] && pass "Check" "$ENABLED" || fail "Check" "$DISABLED"
echo ""
```

Use helpers: `run`, `line N [default]`, `key KEY`
Use status variables: `$ENABLED/$DISABLED`, `$YES/$NO`, etc. (see check.sh lines 9-28)
Use output functions: `pass`, `fail`, `warn`, `info`

### 4. Create Test

```bash
touch tests/test-your-check.sh
chmod +x tests/test-your-check.sh
```

Test pattern:
```bash
#!/bin/bash
result=$(./checks/your-check.sh)
[[ $? -eq 0 ]] || { echo "FAIL: Script error"; exit 1; }
[[ -n "$result" ]] || { echo "FAIL: No output"; exit 1; }
echo "PASS: your-check"
```

### 5. Document in RATIONALE.md

```markdown
### Your Check (`your-check.sh`)

**What it checks:** Brief description

**Security rationale:** Why it matters, what attacks it prevents

**Recommended settings:**
- Setting: `value` (why)

**Sources:**
- [drduh Guide](url) - Prefer this
- [Other source](url)
```

## Coding Standards

```bash
#!/bin/bash                              # Shebang
echo "$variable"                         # Quote variables
[[ $value == "expected" ]]               # Use [[ ]]
defaults read domain key 2>/dev/null     # Suppress expected errors
```

**Naming:**
- Check scripts: `descriptive-name.sh`
- Test scripts: `test-descriptive-name.sh`
- Variables: `lowercase_with_underscores`

## Testing

```bash
./tests.sh                    # All tests
./tests/test-your-check.sh    # Single test
./check.sh                    # Manual test
```

Test on:
- Different macOS versions
- MDM and non-MDM systems
- Various configuration states

## macOS Version Compatibility

For version-specific features:
```bash
if command -v new_command >/dev/null 2>&1; then
    result=$(new_command)
else
    result=$(old_approach)
fi
```

See `software-update.sh` for DDM example (macOS 26+)

## PR Checklist

- [ ] Check script runs without errors
- [ ] Test passes
- [ ] RATIONALE.md updated with sources
- [ ] Follows PATTERNS.md
- [ ] All tests pass
- [ ] Source URL included

## License

By contributing, you agree contributions are licensed under MIT License.
