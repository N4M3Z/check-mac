# macOS Security Check Rationales

Documentation of security checks, their rationale, and recommended settings.

**Primary source:** [drduh/macOS-Security-and-Privacy-Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

## Table of Contents

- [Core System Security](#core-system-security)
- [Network & Firewall](#network--firewall)
- [Privacy & Data Collection](#privacy--data-collection)
- [Application Security](#application-security)
- [User Account Security](#user-account-security)
- [Developer Tools](#developer-tools)
- [MDM & Enterprise](#mdm--enterprise)
- [System Information](#system-information)

---

## Core System Security

### FileVault Encryption (`filevault.sh`)

**What we check:**
- Whether FileVault disk encryption is active
- Hibernate mode configuration

**Why we check it:**
FileVault provides full-disk encryption, protecting your data if the device is stolen or physically accessed. Without it, anyone with physical access can remove your drive and read all data.

Hibernate mode 25 writes RAM to encrypted disk and powers down completely, providing additional protection against physical attacks (cold-boot attacks). However, this setting is marked as informational because it doesn't work reliably on Apple Silicon Macs and can cause system crashes when entering standby. Mode 25 also significantly increases wake time.

**Recommended settings:**
- FileVault: Enabled (`true`)
- `hibernatemode`: `25` (Intel Macs only, for maximum security on portables)

**References:**
- [drduh Guide - Disk Encryption](https://github.com/drduh/macOS-Security-and-Privacy-Guide#full-disk-encryption)
- [Netflix Stethoscope - FileVault](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas osx-config-check #38-39](https://github.com/kristovatlas/osx-config-check)

---

### System Integrity Protection (`sip.sh`)

**What we check:**
- Whether SIP (System Integrity Protection) is enabled

**Why we check it:**
SIP protects core system files and processes from modification, even by administrator accounts or malicious software running as root. This prevents rootkits and system-level malware from persisting by modifying system binaries or kernel extensions. SIP restricts:
- Modification of system files and directories
- Kernel extension loading
- Debugging system processes
- NVRAM variable changes

Disabling SIP significantly weakens macOS security and should only be done temporarily for specific legitimate purposes (like installing kernel extensions for virtualization), then immediately re-enabled.

**Recommended settings:**
- SIP: Enabled (`System Integrity Protection status: enabled`)

**References:**
- [drduh Guide - System Integrity Protection](https://github.com/drduh/macOS-Security-and-Privacy-Guide#system-integrity-protection)
- [Apple Developer - SIP Documentation](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)

---

### Gatekeeper (`gatekeeper.sh`)

**What we check:**
- Whether Gatekeeper assessment is enabled

**Why we check it:**
Gatekeeper verifies that downloaded applications are signed by identified developers and checks them against Apple's malware database before first launch. This prevents execution of tampered or malicious unsigned applications. App Store applications benefit from additional protections like App Sandbox and Hardened Runtime.

Disabling Gatekeeper allows arbitrary code execution without verification, significantly increasing malware risk.

**Recommended settings:**
- Gatekeeper: Enabled (`assessments enabled`)

**References:**
- [drduh Guide - Gatekeeper and XProtect](https://github.com/drduh/macOS-Security-and-Privacy-Guide#gatekeeper-and-xprotect)
- [Apple Support - Gatekeeper](https://support.apple.com/en-us/102445)

---

### XProtect (`xprotect.sh`)

**What we check:**
- Current XProtect malware definitions version
- Age of last XProtect update (days since installation)

**Why we check it:**
XProtect is Apple's built-in antivirus that automatically checks files against known malware signatures. While it can be bypassed by sophisticated attacks, it provides detection for common malware families. Outdated definitions leave systems vulnerable to known malware.

**How age is determined:**
- **macOS 15+ (Sequoia)**: Uses `xprotect version` command for precise timestamp
- **Older macOS**: Falls back to file modification date of XProtect.bundle
- **Pass**: Updated within last 90 days
- **Warn**: Older than 90 days or age unknown
- **Fail**: XProtect not found

**Recommended settings:**
- XProtect version: Current (auto-updated by macOS)
- Update age: Less than 90 days old

**References:**
- [drduh Guide - Gatekeeper and XProtect](https://github.com/drduh/macOS-Security-and-Privacy-Guide#gatekeeper-and-xprotect)
- [Apple Support - XProtect](https://support.apple.com/en-us/102445)
- [Der Flounder - Checking XProtect Update Status](https://derflounder.wordpress.com/2016/03/28/checking-xprotect-and-gatekeeper-update-status-on-macs/)
- [Using the xprotect command in macOS 15](https://macadmin.fraserhess.com/2024/09/16/using-the-xprotect-command-in-macos-15/)

---

### Software Updates (`software-update.sh`)

**What we check:**
- Automatic update checking
- Automatic update downloading
- Critical security update installation
- macOS update installation

**Why we check it:**
Software updates patch known vulnerabilities that attackers actively exploit. Delayed updates leave systems exposed to publicly disclosed vulnerabilities with available exploits. Modern macOS includes rapid security responses (RSR) that deploy critical security fixes quickly without requiring major OS upgrades.

**Note on modern macOS (26+):** Apple migrated to Declarative Device Management (DDM) for software updates. Settings are now in `/var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist` rather than the traditional plist. This check reads from the DDM plist on macOS 26+ and falls back to the old format for older versions.

**Recommended settings:**
- Automatic check: Enabled
- Automatic download: Enabled
- Critical updates: Enabled
- macOS updates: Enabled

**References:**
- [drduh Guide - Keep macOS Current](https://github.com/drduh/macOS-Security-and-Privacy-Guide#update-macos)
- [Netflix Stethoscope - Software Updates](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [Der Flounder - DDM Software Update Settings](https://derflounder.wordpress.com/2025/12/17/reading-ddm-managed-apple-software-update-settings-from-the-command-line-on-macos-tahoe-26-2-0/)

---

### Screen Lock (`screen-lock.sh`)

**What we check:**
- Whether screen lock on sleep/screensaver is enabled
- Screensaver idle time before activation

**Why we check it:**
Automatic screen locking prevents unauthorized access when you step away from your computer. Without it, anyone can access your files, email, and applications while you're away. Autologin defeats FileVault protection—unattended systems with active sessions expose data to physical attackers who don't require password entry.

Short idle timeouts balance security with usability.

**Recommended settings:**
- Screen lock on sleep: Enabled
- Idle time: 300 seconds (5 minutes) or less

**References:**
- [drduh Guide - Screen Lock](https://github.com/drduh/macOS-Security-and-Privacy-Guide#screen-lock)
- [Netflix Stethoscope - Screen Lock](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

## Network & Firewall

### Firewall (`firewall.sh`)

**What we check:**
- Application firewall global state (enabled/disabled)
- Stealth mode (prevents ICMP responses)
- Auto-whitelist for signed applications (should be disabled)

**Why we check it:**
The application firewall blocks incoming connections by default, preventing unauthorized network access. Stealth mode prevents your computer from responding to ICMP ping requests, making reconnaissance more difficult for attackers.

**Auto-whitelist security concern:** The `--setallowsigned` feature automatically allows all code-signed applications to receive incoming connections without user notification. This is risky because attackers can use stolen or compromised developer certificates to sign malware. Recent example: [MacSync Stealer malware](https://www.jamf.com/blog/macsync-stealer-evolution-code-signed-swift-malware-analysis/) (December 2024) was fully signed and notarized, bypassing Gatekeeper and firewall protections.

Disabling auto-whitelist requires explicit user approval for each application requesting incoming connections. However, many organizations enable this via MDM for usability.

**Important limitation:** macOS firewall only blocks incoming connections. For outbound connection monitoring, third-party firewalls like Little Snitch or LuLu detect data exfiltration and command-and-control communications.

**Recommended settings:**
- Firewall state: Enabled
- Stealth mode: Enabled
- Allow signed apps: Disabled (`--setallowsigned off`)

**References:**
- [drduh Guide - Firewall](https://github.com/drduh/macOS-Security-and-Privacy-Guide#firewall)
- [Netflix Stethoscope - Firewall](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas osx-config-check #16-17](https://github.com/kristovatlas/osx-config-check)

---

### Remote Login (`remote-login.sh`)

**What we check:**
- Whether SSH (port 22), Telnet (23), SMB (445), or VNC (5900) are listening

**Why we check it:**
Remote access services are common attack vectors. SSH is frequently targeted by brute-force attacks and vulnerability exploits. Telnet transmits credentials in plaintext and should never be enabled. SMB and VNC also present significant attack surfaces when exposed.

**Recommended settings:**
- No listening services unless explicitly required
- If SSH needed: Use key-based authentication, disable password auth, restrict by IP

**References:**
- [drduh Guide - Remote Access](https://github.com/drduh/macOS-Security-and-Privacy-Guide#ssh)
- [Netflix Stethoscope - Remote Login](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

### Remote Management (`remote-management.sh`)

**What we check:**
- Apple Remote Desktop (ARD) agent status
- Remote Apple Events status
- Wake on Network Access (WOMP) setting

**Why we check it:**
Apple Remote Desktop provides complete remote control of the Mac, including screen sharing and file access. When enabled unnecessarily, it creates a privileged remote access vector. Remote Apple Events allow AppleScript execution from network sources, enabling automated attacks.

Wake on Network Access allows the computer to be woken remotely. While convenient, it keeps network interfaces active during sleep and responds to network packets, potentially enabling attacks against sleeping systems.

**Recommended settings:**
- ARD Agent: Not running (`ard:0`)
- Remote Apple Events: Disabled (`ae:0`)
- Wake on Network: `0` (disabled for portables, optional for desktops)

**References:**
- [drduh Guide - Remote Management](https://github.com/drduh/macOS-Security-and-Privacy-Guide#remote-login-and-screen-sharing)
- [kristovatlas osx-config-check #30-31, #33](https://github.com/kristovatlas/osx-config-check)

---

### DNS Configuration (`dns.sh`)

**What we check:**
- Current DNS servers configured for Wi-Fi interface
- Whether secure/privacy-focused DNS providers are in use

**Note:** Only checks Wi-Fi interface, not Ethernet or other network interfaces.

**Why we check it:**
Unencrypted DNS leaks all visited domains to ISPs and network observers, enabling surveillance and traffic analysis. DNSSEC validation prevents DNS spoofing attacks by verifying cryptographic signatures on DNS records. Privacy-focused DNS providers (Cloudflare, Quad9, Proton) commit to not logging queries or selling data.

**Recommended settings:**
- Use encrypted DNS resolver (DNSCrypt, DoH, or DoT)
- Choose privacy-respecting providers: Cloudflare (1.1.1.1), Quad9 (9.9.9.9), or Proton (76.76.2.0)
- Enable DNSSEC validation where available

**References:**
- [drduh Guide - DNS](https://github.com/drduh/macOS-Security-and-Privacy-Guide#dns)
- [kristovatlas osx-config-check #42](https://github.com/kristovatlas/osx-config-check)

---

### Bluetooth (`bluetooth.sh`)

**What we check:**
- Bluetooth adapter state (on/off)

**Why we check it:**
Bluetooth enables proximity-based tracking and device fingerprinting. BlueBorne and similar Bluetooth vulnerabilities have enabled complete device compromise through wireless proximity attacks. Third-party Bluetooth accessories don't guarantee address randomization, while Apple accessories automatically support BLE Privacy to prevent tracking.

**Recommended settings:**
- Bluetooth: Off when not needed
- If needed: Use Apple accessories supporting BLE Privacy, clear Bluetooth metadata periodically

**References:**
- [drduh Guide - Bluetooth](https://github.com/drduh/macOS-Security-and-Privacy-Guide#bluetooth)
- [kristovatlas osx-config-check](https://github.com/kristovatlas/osx-config-check)

---

### Sharing Services (`sharing.sh`)

**What we check:**
- Printer sharing status
- Internet sharing (NAT daemon) status

**Why we check it:**
Each enabled sharing service expands the attack surface. Printer sharing exposes CUPS web interface and IPP services. Internet sharing creates a NAT gateway, potentially exposing other devices through your Mac. Following the principle of least privilege, disable all sharing services unless actively needed.

**Recommended settings:**
- Printer sharing: Disabled (`0`)
- Internet sharing: Not running (`internet:0`)

**References:**
- [drduh Guide - Sharing Services](https://github.com/drduh/macOS-Security-and-Privacy-Guide#sharing)
- [kristovatlas osx-config-check #26-29, #32](https://github.com/kristovatlas/osx-config-check)

---

## Privacy & Data Collection

### Siri (`siri.sh`)

**What we check:**
- Whether Siri assistant is enabled

**Why we check it:**
Some information is sent to Apple when you use Siri, Siri Suggestions, or Spotlight. This includes search queries and usage patterns, enabling behavioral profiling. The analytics database persists even if Siri is disabled, requiring manual cleanup to prevent metadata accumulation.

**Recommended settings:**
- Siri: Disabled (`0`) for maximum privacy
- If enabled: Review Apple's data collection policies and disable suggestions/Spotlight integration

**References:**
- [drduh Guide - Siri](https://github.com/drduh/macOS-Security-and-Privacy-Guide#siri)

---

### Analytics (`analytics.sh`)

**What we check:**
- Whether automatic diagnostic report submission is enabled

**Why we check it:**
Diagnostic reports contain detailed system information, crash logs, and usage patterns. Automatic submission to Apple creates a comprehensive profile of your system configuration and application usage. While Apple claims anonymization, the volume of data can enable re-identification.

Disabling automatic submission allows manual review of crash reports before submission.

**Recommended settings:**
- Auto-submit diagnostics: Disabled (`0`)

**References:**
- [drduh Guide - Analytics](https://github.com/drduh/macOS-Security-and-Privacy-Guide#analytics)

---

## Application Security

### Finder (`finder.sh`)

**What we check:**
- Whether file extensions are shown for all files

**Why we check it:**
Hidden file extensions enable masquerading attacks where malicious applications disguise themselves. Example: "Evil.jpg.app" appears as an innocent image file when extensions are hidden. Visible extensions provide immediate visual verification of actual file types before execution.

This is critical defense against email attachments and downloaded files that exploit user expectations about file types.

**Recommended settings:**
- Show all extensions: Enabled (`AppleShowAllExtensions: 1`)

**References:**
- [drduh Guide - Miscellaneous](https://github.com/drduh/macOS-Security-and-Privacy-Guide#miscellaneous)

---

### Terminal (`terminal.sh`)

**What we check:**
- Whether Secure Keyboard Entry is enabled in Terminal.app

**Why we check it:**
Secure Keyboard Entry prevents other applications from intercepting keyboard input during terminal sessions. This protects passwords, passphrases, and sensitive commands from keyloggers and malicious applications.

However, it conflicts with certain authentication devices (YubiKey) and text expansion utilities (TextExpander), requiring individual threat model assessment.

**Recommended settings:**
- Secure Keyboard Entry: Enabled (`1`) unless using incompatible tools

**References:**
- [drduh Guide - Terminal](https://github.com/drduh/macOS-Security-and-Privacy-Guide#terminal)

---

## User Account Security

### Autologin (`autologin.sh`)

**What we check:**
- Whether automatic login is configured for any user

**Why we check it:**
Autologin defeats FileVault protection. With autologin enabled, anyone with physical access can simply reboot the machine to gain full access, bypassing disk encryption entirely. FileVault passwords function as firmware passwords preventing unauthorized boot access—autologin disables this protection.

**Recommended settings:**
- Autologin: Not configured (defaults read should fail or return empty)

**References:**
- [drduh Guide - Users](https://github.com/drduh/macOS-Security-and-Privacy-Guide#users)

---

### User Security (`user-security.sh`)

**What we check:**
- Current username
- User group memberships
- Guest account status

**Why we check it:**
Admin accounts have `sudo` access enabling system-wide compromise if exploited. Any program that an admin executes can potentially obtain the same access. Using separate admin and standard user accounts limits privilege escalation attack surface.

Guest accounts provide unauthenticated access to the system, creating an anonymous entry point and eliminating a privilege escalation vector.

**Recommended settings:**
- Use separate admin/standard accounts for daily work
- Guest account: Disabled (`GuestEnabled: 0`)
- Minimize group memberships (principle of least privilege)

**References:**
- [drduh Guide - Users](https://github.com/drduh/macOS-Security-and-Privacy-Guide#users)

---

## Developer Tools

### Homebrew (`homebrew.sh`)

**What we check:**
- Whether Homebrew is installed
- Homebrew bin directory position in PATH
- Analytics opt-out status

**Why we check it:**
PATH positioning matters because attackers can exploit PATH precedence to shadow system utilities with malicious versions. Homebrew's `/usr/local/bin` or `/opt/homebrew/bin` should come before `/usr/bin` only if you consciously want Homebrew packages to override system utilities.

Homebrew analytics collects installation data and usage patterns. Opting out prevents telemetry transmission.

**Recommended settings:**
- PATH: Consider whether Homebrew should override system utilities (depends on use case)
- Analytics: Disabled (`analytics:0`)

**References:**
- [kristovatlas osx-config-check #1-2, #13](https://github.com/kristovatlas/osx-config-check)

---

### Development Tools (`dev-tools.sh`)

**What we check:**
Versions of common development tools against minimum safe versions:
- Git (CVE-2024-32002 and others)
- Curl (CVE-2024-0853 and others)
- OpenSSL (multiple CVE fixes)

**Why we check it:**
Development tools are privileged attack surfaces. Git vulnerabilities have enabled arbitrary code execution during clone/checkout operations. Curl vulnerabilities expose applications to exploitation when fetching remote content. OpenSSL vulnerabilities affect TLS/SSL implementations across the system.

Outdated development tools create supply chain risks—compromised repositories or man-in-the-middle attacks can exploit known vulnerabilities to compromise the development environment and inject malicious code into projects.

**Recommended settings:**
- Git: ≥ 2.45.0 (CVE-2024-32002 fix)
- Curl: ≥ 8.6.0 (CVE-2024-0853 fix)
- OpenSSL: ≥ 3.2.0 (multiple CVE fixes)
- Update regularly via Homebrew or system updates

**References:**
- [kristovatlas osx-config-check #19, #40, #43](https://github.com/kristovatlas/osx-config-check)

---

### Email Security (`gpgmail.sh`)

**What we check:**
- Whether GPGMail (OpenPGP encryption for Apple Mail) is installed
- Whether Proton Mail is installed

**Why we check it:**
Email encryption protects message confidentiality and integrity. GPGMail integrates OpenPGP into Apple Mail, enabling end-to-end encryption. Proton Mail provides end-to-end encrypted email in a zero-knowledge architecture.

**Recommended settings:**
- Consider using GPGMail or Proton Mail for encrypted communications

**References:**
- [drduh Guide - PGP/GPG](https://github.com/drduh/macOS-Security-and-Privacy-Guide#pgpgpg)
- [kristovatlas osx-config-check #78-82](https://github.com/kristovatlas/osx-config-check)

---

## MDM & Enterprise

### Configuration Profiles (`profiles.sh`)

**What we check:**
- MDM enrollment status

**Why we check it:**
Mobile Device Management (MDM) profiles provide centralized security policy enforcement in enterprise environments. They enforce security settings that users cannot modify, ensuring consistent security posture across managed devices.

However, MDM also grants significant control to the enrolling organization, including:
- Remote wipe capability
- Application installation/removal
- Network traffic inspection
- Location tracking
- Restriction of system settings

Personal devices should carefully evaluate MDM enrollment implications. Enterprise-managed devices should verify legitimate organizational enrollment and review applied policies.

**Recommended settings:**
- Informational check only
- Review profiles in System Settings > Privacy & Security > Profiles

**References:**
- [Apple Deployment Guide - MDM Profiles](https://support.apple.com/guide/deployment/intro-to-mdm-profiles-depc0aadd3fe/web)

---

## System Information

### Operating System (`os.sh`)

**What we check:**
- Product name (macOS)
- Product version (e.g., 14.2)
- Build version

**Why we check it:**
OS version information is essential for vulnerability assessment. Each macOS version has known security issues, and older versions no longer receive security updates. Apple typically supports the current macOS version and previous two versions with security updates. Running unsupported versions leaves systems exposed to publicly disclosed vulnerabilities without available patches.

**Recommended settings:**
- Informational check only
- Verify you're running a supported macOS version
- Cross-reference against [Apple security updates](https://support.apple.com/HT201222)

**References:**
- [drduh Guide - Keep macOS Current](https://github.com/drduh/macOS-Security-and-Privacy-Guide#update-macos)
- [Netflix Stethoscope - OS](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

### Hardware Information (`hardware.sh`)

**What we check:**
- Model Identifier
- Serial Number

**Why we check it:**
Hardware information is essential for:
- **Asset management:** Tracking device inventory in enterprise environments
- **Vulnerability assessment:** Certain hardware models have specific vulnerabilities (e.g., Thunderbolt DMA attacks on pre-T2 Macs)
- **Firmware verification:** T2/Apple Silicon Macs provide hardware-verified secure boot
- **Theft recovery:** Serial numbers identify stolen devices

Modern Apple Silicon and T2 Macs provide significant security improvements over earlier Intel Macs, including hardware-verified secure boot chain, hardware-backed encryption keys, DMA protection, and separate security processor.

**Recommended settings:**
- Informational check only
- No pass/fail criteria

**References:**
- [Netflix Stethoscope - Hardware](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

## Closing Thoughts

- No single control provides complete protection. Multiple layers ensure that exploitation requires overcoming multiple independent defenses.
- Before implementing all recommendations, establish your own threat model by identifying what needs protection and against what adversary.
- Security measures should match actual threats. Excessive restrictions reduce system utility without proportional benefit.

*Security recommendations evolve with threat landscapes and platform updates. Regularly review and update security configurations.*

### References

- [drduh macOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide) - Comprehensive hardening guide
- [kristovatlas osx-config-check](https://github.com/kristovatlas/osx-config-check) - Automated configuration checking
- [Netflix Stethoscope](https://github.com/Netflix-Skunkworks/stethoscope-app) - User-focused security posture checking
- [Apple Platform Security Guide](https://support.apple.com/guide/security/welcome/web) - Official Apple security documentation
- [NIST macOS Security Compliance Project](https://github.com/usnistgov/macos_security) - Government security baseline
