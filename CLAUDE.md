# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`check-mac` is a macOS security health check shell tool. `check.sh` orchestrates independent check scripts under `checks/`, each auditing one facet of the system (FileVault, firewall, SIP, remote access, etc.). Output is human-readable with colored status symbols.

Authoritative reading order for context: [README.md](README.md) for the user-facing framing, then the three ADRs under [docs/decisions/](docs/decisions) for design intent.

## Critical caveat

Apple is deprecating plist-based configuration in favor of Declarative Device Management. On macOS 15+ / 26+, `defaults read` returns nothing for many settings that have moved into managed profile payloads. The tool surfaces this as a fourth severity, **UNKNOWN**, rather than silently passing or failing. See [ARCH-0003 Handle Managed Devices](docs/decisions/ARCH-0003 Handle Managed Devices.md) for the policy and the canonical implementation pattern (`checks/software-update.sh`).

Before "fixing" a check that returns UNKNOWN, verify the setting via `sudo profiles show -output stdout-xml` or the relevant native CLI (`fdesetup`, `csrutil`, `spctl`, `pmset`, `systemsetup`, `scutil`). README points users to the NIST `macos_security` project for compliance-grade auditing.

## Architecture

```text
check.sh                 orchestrator: sources lib/, calls run(), formats output, --strict for CI
lib/style.sh             colors, Nagios codes (OK/WARN/CRIT/INFO/UNKNOWN), status strings
lib/helpers.sh           run(), key(), check(), pass/fail/warn/info/unknown, issues + unknowns counters
checks/*.sh              independent scripts, one topic each (canonical examples)
docs/decisions/          architecture decision records (ARCH-NNNN)
CONTRIBUTING.md          contribution workflow with check template
```

Data flow: orchestrator calls `data=$(run <name>)` which executes `checks/<name>.sh` and captures its `variable:value` lines. `key <name>` extracts a specific value from `$data`. `check <code> <label> <pass_msg> <fail_msg>` dispatches the severity code to `pass`/`warn`/`fail`/`info`/`unknown` display helpers.

Severity codes flow from check scripts to display: `0` OK, `1` WARN, `2` CRIT, `3` INFO, `4` UNKNOWN. Constants are defined in both `lib/style.sh` and inline in every check script. The duplication is intentional, see [ARCH-0002 Nagios Return Codes](docs/decisions/ARCH-0002 Nagios Return Codes.md).

## Commands

```sh
./check.sh                                 # full audit, exits 0 always
./check.sh --strict                        # exits non-zero on any issue or Unknown (CI mode)
./check.sh --help                          # show flags
./checks/filevault.sh                      # run one check, prints raw variable:value
shellcheck checks/*.sh lib/*.sh check.sh   # lint before committing
chmod +x checks/<new>.sh                   # required after creating a new check
```

There is no build step, test framework, or package manager. Each check script is its own test harness: run it and inspect the `pass_*` lines.

## Adding a check

1. Copy the template from [CONTRIBUTING.md](CONTRIBUTING.md) into `checks/<name>.sh`, or start from an existing script (`checks/siri.sh` is the simplest reference). The file structure (retrieve, Nagios constants, test, output) is non-negotiable because the orchestrator and future readers rely on it.
2. `chmod +x checks/<name>.sh` and verify standalone output.
3. Wire into `check.sh` via `data=$(run <name>)` then `check "$(key pass_<var>)" "<Label>" "$ENABLED" "$DISABLED"` (or the list/display-value variants shown in existing checks).
4. Carry a `# Source:` comment at the top pointing to the upstream reference (drduh guide, stethoscope, osx-config-check, Apple docs).
5. Reuse status strings from `lib/style.sh` (`$ENABLED`, `$DISABLED`, `$LISTENING`, `$INSTALLED`, etc.) rather than hardcoding.
6. If the check reads a `defaults` key that may be managed by a profile, follow the UNKNOWN-aware pattern: default severity is `$UNKNOWN`, flip to `$OK` on positive match, flip to `$WARN`/`$CRIT` on observed misconfiguration. Empty source stays UNKNOWN. See `checks/siri.sh` or `checks/software-update.sh` for examples.

## Conventions specific to this repo

- Bash pattern matching over subprocesses: `[[ "$s" == *enabled* ]]`, not `echo "$s" | grep`.
- Multi-line command substitution for readability:
    ```sh
    setting=$(
        defaults read com.apple.foo Bar 2>/dev/null
    )
    ```
- Guard external CLI probes so they do not provoke installers. `git --version` on a fresh Mac without Xcode CLT triggers the GUI installer mid-audit; wrap with `command -v` and `xcode-select -p`. See `checks/dev-tools.sh`.
- Probe new managed-device CLIs first, fall back to legacy `defaults`:
    ```sh
    if command -v new_command >/dev/null 2>&1; then
        result=$(new_command 2>/dev/null)
    else
        result=$(old_command 2>/dev/null)
    fi
    ```
    `checks/software-update.sh` is the canonical example.
- Suppress expected errors (`2>/dev/null`); an absent plist or unset key is the common case, not an exception to surface, but it must surface as UNKNOWN, not as silent OK.
- The default severity for a check is `$UNKNOWN`, flipped to `$OK` only on positive match. This makes "could not retrieve the value" fail safe rather than silent. WARN and CRIT are reserved for observed misconfigurations.
