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

## ⚠️ Caveats

**This tool has fundamental limitations due to how macOS handles security settings:**

1. **`defaults read` doesn't work reliably** - Most security settings don't appear in preference files unless explicitly changed from defaults. This means we can't verify what's actually configured vs. what we assume is the default.

2. **Apple is deprecating plist-based configuration** - Modern macOS versions (15+/26+) are moving to Declarative Device Management (DDM). Many settings we tried to check (Safari security, Mail privacy, login window) simply can't be verified via `defaults read` anymore.

3. **We removed multiple checks** - During development, we removed Safari, Mail, and loginwindow checks because they were unreliable/broken on modern macOS.

**For serious security auditing, use the official NIST tool instead:**

- **[macOS Security Compliance Project](https://github.com/usnistgov/macos_security)** - Official NIST tool with modern API access
- **[NIST Documentation](https://pages.nist.gov/macos_security/)** - Supports NIST 800-53, CIS, DISA STIG compliance frameworks

This tool remains useful for:
- Quick, lightweight security checks
- Learning bash and security concepts
- Basic system inventory

But don't rely on it for comprehensive security auditing or compliance validation.

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

- [RATIONALE.md](RATIONALE.md) - Security rationale for each check
- [PATTERNS.md](PATTERNS.md) - Check script patterns
- [CLAUDE.md](CLAUDE.md) - Claude Code codebase documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

## Compatibility

- macOS 15+ (Sequoia): Full support
- macOS 26+ (Tahoe): DDM-aware
- Apple Silicon & Intel supported
- MDM-aware

## License

[MIT License](LICENSE)
