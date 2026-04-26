# Contributing

## Adding a New Check

1. **Create the check script** following the template below. Existing scripts under `checks/` are the canonical examples; `checks/siri.sh` is the simplest reference. The standard template defaults severity to `$UNKNOWN` and only flips on positive evidence:

    ```sh
    #!/bin/bash
    # Source: URL

    # Retrieve value
    setting=$(
        defaults read com.example.plist Key 2>/dev/null
    )

    # Test logic
    OK=0; WARN=1; CRIT=2; INFO=3; UNKNOWN=4

    pass_check=$UNKNOWN
    [[ "$setting" == "expected" ]] && pass_check=$OK
    [[ "$setting" == "bad-value" ]] && pass_check=$WARN

    # Output
    echo "pass_check:$pass_check"
    ```

2. **Make it executable:** `chmod +x checks/your-check.sh`.

3. **Add to `check.sh`** orchestrator:

    ```sh
    data=$(run your-check)
    check "$(key pass_check)" "Check Name" "$ENABLED" "$DISABLED"
    ```

## Coding Standards

- Quote variables: `"$variable"`
- Use `[[ ]]` for tests
- Suppress expected errors: `2>/dev/null`
- Multi-line command substitution for readability
- Include source URL in a `# Source:` comment at the top of the script
- Use status variables from `lib/style.sh` (`$ENABLED`, `$DISABLED`, etc.) rather than hardcoding
- Default severity is `$UNKNOWN`, never apply `${var:-default}` defaulting that masks empty source
- Guard external CLI probes with `command -v` (and `xcode-select -p` for Xcode tools) so they do not provoke the GUI installer on a fresh Mac
- Run `shellcheck checks/*.sh lib/*.sh check.sh` before submitting

## macOS Version Compatibility

Probe new managed-device CLIs first, fall back to legacy `defaults`:

```sh
if command -v new_command >/dev/null 2>&1; then
    result=$(new_command 2>/dev/null)
else
    result=$(old_command 2>/dev/null)
fi
```

See `checks/software-update.sh` for a worked example. Empty source after both probes must surface as UNKNOWN, see [ARCH-0003 Handle Managed Devices](docs/decisions/ARCH-0003 Handle Managed Devices.md).

## License

By contributing, you agree contributions are licensed under [EUPL-1.2](LICENSE).
