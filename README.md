# check-mac

## Description

Lightweight macOS security smoke test. Audits a Mac in a single shell run against drduh's [macOS Security and Privacy Guide][DRDUH] and a handful of other prior-art baselines.

This is a smoke test, not a compliance gate. For compliance auditing use [usnistgov/macos_security][NIST]. See [ARCH-0001 Tool Scope and Limitations](docs/decisions/ARCH-0001 Tool Scope and Limitations.md) for what the tool deliberately does not check.

Built with [Claude Code](CLAUDE.md), contributions welcome.

## Compatibility

Apple Silicon and Intel. macOS 12 Monterey through macOS 26 Tahoe. MDM-aware, with explicit handling of [Declarative Device Management][DDM] managed sources via UNKNOWN results, see [ARCH-0003 Handle Managed Devices](docs/decisions/ARCH-0003 Handle Managed Devices.md).

## Installation

Requires macOS and Xcode Command Line Tools. No Homebrew or other dependencies.

```sh
xcode-select --install                              # if not already installed
git clone https://github.com/N4M3Z/check-mac.git
cd check-mac
```

## Usage

```sh
./check.sh                  # status display, exits 0 always
./check.sh --strict         # exits non-zero on any issue or Unknown
./check.sh --help           # show flags
./checks/filevault.sh       # any single check is independently runnable
```

### Output legend

| Symbol | Meaning                                          |
| ------ | ------------------------------------------------ |
| ✓      | Pass, observed and matches expected              |
| ✗      | Fail, critical issue                             |
| !      | Warn, recommended fix                            |
| ℹ      | Info, no action needed                           |
| ?      | Unknown, could not determine, verify manually    |
| ⚙      | MDM, managed setting                             |

`./check.sh` always exits 0 by default. The issues counter is a visual cue for humans. Use `--strict` to exit non-zero when any check fails, warns, or returns Unknown (suitable for CI or bootstrap gates). See [ARCH-0002 Nagios Return Codes](docs/decisions/ARCH-0002 Nagios Return Codes.md).

### Coverage

A baseline across these areas:

- **Core security**: FileVault, SIP, Gatekeeper, XProtect, software updates, screen lock
- **Network**: firewall, stealth mode, remote login, DNS, Bluetooth, sharing
- **Privacy**: Siri, analytics, Finder extensions, Terminal secure-keyboard
- **User security**: auto-login, guest account, admin rights
- **Applications**: secure email apps, password managers, VPN
- **Developer tools**: Homebrew, Git/Curl/OpenSSL versions

For the full list, run `./check.sh`. For what the tool does **not** cover (persistence, profile payloads, kernel/system extensions, secure-boot policy, recovery-key escrow, Activation Lock), see [ARCH-0001](docs/decisions/ARCH-0001 Tool Scope and Limitations.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and [docs/decisions/](docs/decisions) for architectural decisions. Existing scripts under `checks/` are the canonical examples (start with `checks/siri.sh` for the simplest UNKNOWN-aware pattern).

## Requirements

| Dependency               | Required | Purpose                            |
| ------------------------ | -------- | ---------------------------------- |
| Xcode Command Line Tools | Yes      | Provides `git` and basic toolchain |
| `shellcheck`             | Optional | Linting before contributing        |

## License

[EUPL-1.2](LICENSE)

[DRDUH]: https://github.com/drduh/macOS-Security-and-Privacy-Guide
[NIST]: https://github.com/usnistgov/macos_security
[DDM]: https://developer.apple.com/documentation/devicemanagement/leveraging-the-declarative-device-management-data-model-and-status-reports
