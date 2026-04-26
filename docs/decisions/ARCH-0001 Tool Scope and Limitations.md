---
title: "Tool Scope and Limitations"
description: "check-mac is a smoke test, not a compliance gate; codifies what the tool deliberately does not check"
type: adr
category: governance
tags:
    - scope
    - non-goals
    - governance
status: accepted
created: 2026-04-26
updated: 2026-04-26
author: "@N4M3Z"
project: check-mac
related:
    - "ARCH-0002 Nagios Return Codes.md"
    - "ARCH-0003 Handle Managed Devices.md"
responsible: ["@N4M3Z"]
accountable: ["@N4M3Z"]
consulted: []
informed: []
upstream: []
---

# Tool Scope and Limitations

## Context and Problem Statement

check-mac audits a Mac against a security baseline. The README has accumulated framing ("48 checks across 16 categories") that overstates coverage relative to what `defaults read` and a handful of `*ctl` CLIs can observe in 2026, when [Apple Declarative Device Management][DDM] has moved most policy out of the legacy plist domain. Without an explicit scope statement, contributors keep proposing additions that gradually push the project toward NIST-parity coverage shell cannot honestly deliver, and users trust the tool for decisions it was never built to support. The compliance-grade project already exists: [usnistgov/macos_security][NIST].

## Decision Drivers

- Honest framing of what a green run does and does not warrant
- Single shell run on a fresh Mac with no external toolchain
- Reviewer leverage for declining scope-creep PRs
- Clear handoff to NIST, osquery, and Pareto for everything we deliberately do not cover

## Considered Options

1. **Expand to NIST parity in shell** — port every CIS/STIG control. The sources NIST queries (mobileconfig payloads, system-extension state, secure-boot attributes) are not reliably accessible via `defaults read` and require Swift or Objective-C system APIs.
2. **Wrap NIST `macos_security`** — drive the Python toolchain from this repo. Introduces a Python dependency that breaks the "single shell run on a fresh Mac" property.
3. **Smoke test with explicit scope and limitations** — keep the shell-only, sub-minute audit footprint and tell users what to use for compliance.

## Decision Outcome

Chosen option: **Smoke test with explicit scope and limitations**, because it preserves the tool's strengths (zero-dep, fast, readable) and resolves the calibration problem at the source: stop implying coverage we cannot honestly deliver.

The tool does **not** check, and will not grow to check:

| Out of scope                                            | Where to look instead                            |
| ------------------------------------------------------- | ------------------------------------------------ |
| Persistence: LaunchAgents, LaunchDaemons, login items   | `launchctl list`, NIST baseline                  |
| Configuration profile payload contents                  | `profiles show -output stdout-xml`               |
| Kernel and system extensions                            | `kmutil showloaded`, `systemextensionsctl list`  |
| Apple Silicon secure-boot policy                        | `bputil -d`                                      |
| FileVault recovery-key escrow target                    | `fdesetup status -extended`                      |
| Activation Lock, Find My state                          | System Settings, MDM console                     |
| Browser extension inventory                             | Browser-specific tooling                         |
| Notarization or codesign audit of installed apps        | `spctl --assess`, NIST baseline                  |
| TCC privacy grants (Full Disk Access, Screen Recording) | `tccutil`, NIST baseline                         |

These are valuable. They belong in [NIST `macos_security`][NIST], in [osquery / Fleet][FLEET], in [Pareto Security][PARETO], or in a sibling tool. They do not belong here.

### Consequences

- [+] Reviewers can decline scope-creep PRs by pointing at this ADR
- [+] New contributors know within one read where to draw the line
- [+] Users get an honest framing of what a green run does and does not warrant
- [-] A user expecting compliance coverage may be disappointed, so the README must surface the smoke-test framing prominently
- [-] Some valuable adjacent checks (Lockdown Mode, Advanced Data Protection, Touch-ID-for-sudo) require separate tooling rather than being added here

## Related Decisions

- [ARCH-0002 Nagios Return Codes](ARCH-0002 Nagios Return Codes.md) — the per-check contract within this scope
- [ARCH-0003 Handle Managed Devices](ARCH-0003 Handle Managed Devices.md) — how the tool handles managed sources within this scope

## Links

- [usnistgov/macos_security][NIST] — the compliance-grade project this tool defers to
- [Pareto Security][PARETO] — adjacent open-source posture-check tool, currently maintained
- [Fleet macOS CIS queries][FLEET] — osquery SQL for every CIS macOS control, useful as a reference oracle

[DDM]: https://developer.apple.com/documentation/devicemanagement/leveraging-the-declarative-device-management-data-model-and-status-reports
[NIST]: https://github.com/usnistgov/macos_security
[PARETO]: https://github.com/ParetoSecurity/pareto-mac
[FLEET]: https://github.com/fleetdm/fleet/tree/main/ee/cis
