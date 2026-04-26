---
title: "Handle Managed Devices"
description: "Empty defaults read or missing CLI surfaces as UNKNOWN, not OK; OK requires positive evidence; UNKNOWN is default-on"
type: adr
category: architecture
tags:
    - architecture
    - managed-devices
    - declarative-device-management
    - unknown
    - severity
    - fail-safe
status: accepted
created: 2026-04-26
updated: 2026-04-26
author: "@N4M3Z"
project: check-mac
related:
    - "ARCH-0001 Tool Scope and Limitations.md"
    - "ARCH-0002 Nagios Return Codes.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Handle Managed Devices

## Context and Problem Statement

Apple is moving Mac configuration to [Declarative Device Management][DDM]. On macOS 15+ / 26+ many settings live in profile payloads invisible to `defaults read`. A check that reads `defaults read com.apple.foo Bar` and sees nothing has historically defaulted to either OK (silent pass) or CRIT (false alarm). Both are wrong.

Silent OK produces a *false sense of safety* on exactly the corporate Macs the tool is most often run against: the user sees a green check for "Analytics: Disabled" and trusts it, when in reality the legacy plist domain is silent because the policy now lives in a managed profile this tool cannot read. Silent CRIT produces a CRIT storm on every fresh managed install, training users to ignore the red markers, which is worse than no signal at all.

The right answer is to acknowledge that the source is silent, mark the result as undetermined, and tell the user to verify manually.

## Decision Drivers

- Security tools must fail safe, not silent
- OK should mean "observed and matches expected", not "did not see anything bad"
- A separate signal is needed for "could not determine" so users know where to look
- The change must propagate end-to-end: severity, counter, summary, legend, and per-check logic

## Considered Options

1. **Treat empty source as INFO** — reuses the existing "informational, no action" bucket. Conflates "no action needed" with "manual verification required" and loses the actionability of UNKNOWN.
2. **Treat empty source as OK** — current behavior in several scripts. Manufactures the false-OK bug this ADR exists to fix.
3. **Treat empty source as CRIT** — current behavior elsewhere. CRIT storm on every managed Mac, trains users to ignore alerts.
4. **Add UNKNOWN as a fourth severity, default-on for empty sources** — explicit indeterminate signal, propagated end-to-end.
5. **Add UNKNOWN but gate it behind `--strict`** — preserves current behavior for casual users. Hides the false-OK bug from everyone who does not read the docs.

## Decision Outcome

Chosen option: **UNKNOWN as a fourth severity, default-on (option 4)**.

UNKNOWN is `4` in the Nagios extension, displayed as `?` in cyan. It is the default outcome when:

- A `defaults read` returns empty for a key whose factory default is undocumented or managed
- An external CLI (`fdesetup`, `csrutil`, `spctl`, `pmset`) is missing or returns no output
- A configuration profile payload could override the legacy plist domain that the check inspects

OK requires *positive* evidence: a passing check has read a value and confirmed it matches the expected setting. WARN and CRIT remain reserved for *observed* misconfigurations. INFO stays the orchestrator's "informational, no action needed" bucket. UNKNOWN means "we could not determine the state, manual verification recommended."

Default-on, not opt-in. Hiding indeterminate state behind a flag preserves the silent-OK bug for everyone who does not read the docs.

### Canonical implementation pattern

`checks/software-update.sh` is the model. Probe the new managed-device CLI first, fall back to legacy `defaults`, surface UNKNOWN if both are silent. Back-port to `checks/siri.sh`, `checks/analytics.sh`, `checks/finder.sh`, `checks/terminal.sh`, `checks/autologin.sh`, and the managed branches of `checks/software-update.sh`.

### Implementation surface

The state propagates end-to-end. Adding UNKNOWN required changing:

| File                       | Change                                                                  |
| -------------------------- | ----------------------------------------------------------------------- |
| `lib/style.sh`             | New `UNKNOWN=4` constant and `CHECK_UNKNOWN` symbol                     |
| `lib/helpers.sh`           | New `4)` case in `check()`, `unknown()` helper, `pass_unknown` counter  |
| `check.sh`                 | Surface unknowns in summary, include in `--strict` non-zero condition   |
| `README.md`                | New row in the legend table, smoke-test framing references this ADR     |
| Affected `checks/*.sh`     | Convert empty-source paths to UNKNOWN per the canonical pattern         |

Under `--strict`, exit non-zero when `issues + unknowns > 0`. UNKNOWNs are treated as failures for CI purposes because a CI gate cannot defer to a human for manual verification.

### Consequences

- [+] OK becomes meaningful: every passing check reflects positive evidence
- [+] No false-OKs on managed Macs
- [+] Users get explicit "?" markers showing where manual verification is needed
- [-] A previously-clean run will now show several UNKNOWN markers on most Macs. This is the correct answer, so the README and runtime legend must explain it
- [-] CI consumers of `--strict` see more failures, which is the intended behavior but requires a one-time triage pass per environment

## Related Decisions

- [ARCH-0001 Tool Scope and Limitations](ARCH-0001 Tool Scope and Limitations.md) — defines what we audit, UNKNOWN handles indeterminate sources within that scope
- [ARCH-0002 Nagios Return Codes](ARCH-0002 Nagios Return Codes.md) — the severity contract this ADR extends

## Links

- [Apple Declarative Device Management][DDM] — the management framework that drives the false-OK problem on macOS 15+ / 26+
- `derflounder.wordpress.com` — practical writeup on reading managed software-update settings, used as the basis for the canonical implementation pattern in `checks/software-update.sh`

[DDM]: https://developer.apple.com/documentation/devicemanagement/leveraging-the-declarative-device-management-data-model-and-status-reports
