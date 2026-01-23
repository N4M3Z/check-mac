# check-mac

macOS security health check tool auditing your system against security best practices.

Based on:
- [drduh's macOS Security Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)
- [Netflix Stethoscope](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas/osx-config-check](https://github.com/kristovatlas/osx-config-check)

Built with [Claude Code](CLAUDE.md), contributions welcome.

## Quick Start

```bash
git clone https://github.com/yourusername/check-mac.git
cd check-mac
./check.sh
```

## What It Checks

48 security checks across 16 categories:
- **Core Security**: FileVault, SIP, Gatekeeper, XProtect, software updates, screen lock
- **Network**: Firewall, stealth mode, remote access, DNS, Bluetooth, sharing
- **Privacy**: Siri, analytics, Finder extensions
- **User Security**: Auto-login, guest account, admin rights
- **Applications**: Email apps, password managers, VPN
- **Developer Tools**: Homebrew, Git/Curl/OpenSSL versions


## ⚠️ Caveats

**This tool has fundamental limitations due to how macOS handles security settings:**

**Apple is deprecating plist-based configuration** - Modern macOS versions (15+/26+) are moving to Declarative Device Management (DDM) which is why **`defaults read` doesn't work reliably** for modern version of Apple Mail or Safari. Most security settings don't appear in preference files unless explicitly changed from defaults. This means we can't verify what's actually configured vs. what we assume is the default.

**For serious security auditing, use the official NIST tool instead:**

- [macOS Security Compliance Project](https://github.com/usnistgov/macos_security)
- [NIST Documentation](https://pages.nist.gov/macos_security/)

This tool remains useful for:
- Quick, lightweight security checks
- Learning bash and security concepts
- Basic system inventory

Don't rely on this for comprehensive security auditing and especially for compliance validation.

## Output

| Symbol | Meaning                 |
|--------|-------------------------|
|   ✓    | Pass - optimal setting  |
|   ✗    | Fail - critical issue   |
|   !    | Warn - recommended fix  |
|   ℹ    | Info - no action needed |
|   ⚙    | MDM - managed setting   |

## Documentation

- [RATIONALE.md](RATIONALE.md) - Security rationale for each check
- [PATTERNS.md](PATTERNS.md) - Check script patterns
- [CLAUDE.md](CLAUDE.md) - Claude Code codebase documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

## Compatibility

- Apple Silicon & Intel supported
- MDM-aware

## License

- [MIT License](LICENSE)
