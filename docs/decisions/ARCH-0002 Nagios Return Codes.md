---
title: "Nagios Return Codes"
description: "Each check script is independently runnable and emits Nagios-coded key:value pairs; orchestrator exit-code semantics defined"
type: adr
category: architecture
tags:
    - architecture
    - nagios
    - return-codes
    - exit-codes
status: accepted
created: 2026-04-26
updated: 2026-04-26
author: "@N4M3Z"
project: check-mac
related:
    - "ARCH-0001 Tool Scope and Limitations.md"
    - "ARCH-0003 Handle Managed Devices.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Nagios Return Codes

## Context and Problem Statement

The repo holds independent check scripts under `checks/` plus an orchestrator `check.sh` that consumes them. The contract between them is load-bearing: change it without thinking and every check breaks. New contributors need to understand it immediately. Without a written rationale, the recurring "why does every check redefine `OK=0; WARN=1; CRIT=2; INFO=3` instead of sourcing the lib?" question keeps coming up.

A separate question is the orchestrator's exit-code semantics. By default `check.sh` always exits 0, so a human reading the colored summary sees the right thing while a script wiring it into CI cannot distinguish a clean run from a failed one. That mismatch needs an explicit, documented resolution rather than a silent default.

## Decision Drivers

- Each check must be runnable on its own with `./checks/<name>.sh`, no matter the working directory
- Adding or removing a check must require zero coordination with existing ones
- The orchestrator must be replaceable without touching any check
- CI integration must be possible without breaking the existing interactive use case

## Considered Options

1. **Source `lib/style.sh` from every check** — single source of truth for severity constants. Breaks standalone runnability when run from a different working directory, couples every check to the orchestrator's layout.
2. **Inline severity constants per check** — three lines duplicated in every script (`OK=0; WARN=1; CRIT=2; INFO=3`). Each script is fully self-contained.
3. **Hybrid with optional source plus inline fallback** — try to source `lib/codes.sh` if reachable, fall back to inline. Most resilient, slight complexity bump.
4. **Default to non-zero exit on any issue** — surprises every interactive user, breaks pipes through `tee` or `less`. Considered and rejected.
5. **Opt-in `--strict` flag for non-zero exit** — interactive default unchanged, CI users opt in explicitly.

## Decision Outcome

Chosen option: **Inline severity constants per check (option 2) with opt-in `--strict` for CI exit codes (option 5)**.

### Per-check contract

- Shebang `#!/bin/bash`, executable bit set, runnable as `./checks/<name>.sh` without sourcing any lib.
- Output is `key:value` lines on stdout. Severity codes follow [Nagios convention][NAGIOS]: `0` OK, `1` WARN, `2` CRIT, `3` INFO. (See [ARCH-0003 Handle Managed Devices](ARCH-0003 Handle Managed Devices.md) for the fourth code.)
- A check emits `pass_<variable>:<code>` for each tested condition, plus any display values (versions, lists) the orchestrator needs.
- Each check defines its own `OK=0; WARN=1; CRIT=2; INFO=3` constants inline. The duplication is intentional and required by the standalone-runnable property.

### Orchestrator contract

`check.sh` sources `lib/style.sh` (colors, status strings) and `lib/helpers.sh` (`run`, `key`, `check`, severity dispatch) once at startup. It calls `data=$(run <name>)` to execute a check, extracts values via `key <name>`, and dispatches severity codes to `pass`/`fail`/`warn`/`info`/`unknown` display helpers.

### Exit-code semantics

| Mode       | Behavior                                                                              |
| ---------- | ------------------------------------------------------------------------------------- |
| Default    | Always exit `0`. The issues counter is a visual cue for humans.                       |
| `--strict` | Exit `1` when any check fails, warns, or returns Unknown. For CI and bootstrap gates. |

The default is preserved deliberately. Many users invoke `./check.sh` interactively and pipe through `tee` or `less`. Flipping the default to non-zero would surprise everyone who has not read the change log.

### Consequences

- [+] Each check is its own test harness: run it, read the `pass_*` lines
- [+] The orchestrator can be replaced or rewritten without touching any check
- [+] Adding a new check requires zero coordination with existing ones
- [+] CI users have an explicit, documented opt-in
- [-] Severity constants are duplicated in every check (about three lines per file). Synchronization risk if the codes ever change. Mitigation: `set -u` in checks plus an optional `lib/codes.sh` micro-source for checks that prefer to import.

## Related Decisions

- [ARCH-0001 Tool Scope and Limitations](ARCH-0001 Tool Scope and Limitations.md) — the scope this contract operates within
- [ARCH-0003 Handle Managed Devices](ARCH-0003 Handle Managed Devices.md) — extends the severity codes with UNKNOWN

## Links

- [Nagios Plugin Development Guidelines][NAGIOS] — origin of the 0/1/2/3 severity code convention
- `lib/helpers.sh:14` — `key()` uses `cut -d: -f2-` so values containing colons (IPv6 addresses, status strings, hostnames with ports) are not silently truncated
- `lib/helpers.sh:33-46` — `check()` dispatches the integer code to the appropriate display helper
- `check.sh` — parses `--strict` and `--help` at startup, flag handling stays minimal by design

[NAGIOS]: https://nagios-plugins.org/doc/guidelines.html#AEN78
