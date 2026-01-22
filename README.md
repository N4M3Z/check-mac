# check-mac

macOS security health check tool auditing your system against security best practices.

Based on:
- [drduh's macOS Security Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)
- [Netflix Stethoscope](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas/osx-config-check](https://github.com/kristovatlas/osx-config-check)

Vibe-coded with [Claude Code](CLAUDE.md), contributions welcome.

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

## Output

| Symbol | Meaning                 |
|--------|-------------------------|
|   ✓    | Pass - optimal setting  |
|   ✗    | Fail - critical issue   |
|   !    | Warn - recommended fix  |
|   ℹ    | Info - no action needed |
|   ⚙    | MDM - managed setting   |

## Documentation

- **[RATIONALE.md](RATIONALE.md)** - Security rationale for each check
- **[PATTERNS.md](PATTERNS.md)** - Check script patterns
- **[CLAUDE.md](CLAUDE.md)** - Claude Code codebase documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute

## Compatibility

- macOS 15+ (Sequoia): Full support
- macOS 26+ (Tahoe): DDM-aware
- Apple Silicon & Intel supported
- MDM-aware

## License

[MIT License](LICENSE.md)
