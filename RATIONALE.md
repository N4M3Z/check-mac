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

**What it checks:**
- Whether FileVault disk encryption is active
- `destroyFVKeyOnStandby` setting (removes encryption key from memory on standby)
- Hibernate mode configuration (secure sleep settings)

**Security rationale:**
FileVault provides full-disk encryption, making data inaccessible if the device is stolen or physically accessed. FileVault makes it so that you need to enter a password in order to access the data on your drive. The FileVault password also functions as a firmware password, preventing unauthorized boot attempts and single-user mode access.

The `destroyFVKeyOnStandby` setting removes the FileVault key from memory during standby mode, preventing cold-boot attacks and direct memory access (DMA) attacks on sleeping systems. Hibernate mode 25 writes RAM to encrypted disk and removes power, providing additional protection against sophisticated physical attacks.

**Recommended settings:**
- FileVault: Enabled (`true`)
- `destroyFVKeyOnStandby`: `1` (enabled)
- `hibernatemode`: `25` (for maximum security on portables)

**Why marked as `info` not `fail`:**
These pmset settings are informational because:
1. **M1/Apple Silicon compatibility**: Settings don't work reliably on Apple Silicon Macs
2. **Known bugs**: Combined settings can cause system crashes when entering standby
3. **Usability trade-off**: Mode 25 significantly increases wake time and requires password every time

**Sources:**
- [drduh Guide - Disk Encryption](https://github.com/drduh/macOS-Security-and-Privacy-Guide#full-disk-encryption)
- [Netflix Stethoscope - FileVault](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas osx-config-check #38-39](https://github.com/kristovatlas/osx-config-check)

---
#TODO: I have rewritten the following rationale, please adjust all the others to match. Use less pompous language.

### System Integrity Protection (`sip.sh`)

**What we check:**
- Whether [SIP](https://reference) (System Integrity Protection) is enabled

**Why we check it:**
[SIP](https://reference) protects core system files and processes from modification, even by administrator accounts or malicious software running as root. This prevents rootkits and system-level malware from persisting by modifying system binaries or kernel extensions. [SIP](https://reference) restricts:
- Modification of system files and directories (source?)
- Kernel extension loading (source?)
- Debugging system processes (source?)
- NVRAM variable changes (source?)

Disabling [SIP](https://reference) significantly weakens macOS security and should only be done temporarily for specific legitimate purposes (like installing kernel extensions for virtualization), then immediately re-enabled.

**Recommended settings:**
- SIP: Enabled (`System Integrity Protection status: enabled`)

**References:**
- [drduh Guide - System Integrity Protection](https://github.com/drduh/macOS-Security-and-Privacy-Guide#system-integrity-protection)
- [Apple Developer - SIP Documentation](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)

#ENDOFTODO
---

### Gatekeeper (`gatekeeper.sh`)

**What it checks:**
- Whether Gatekeeper assessment is enabled

**Security rationale:**
Gatekeeper verifies that downloaded applications are signed by identified developers and checks them against Apple's malware database before first launch. This prevents execution of tampered or malicious unsigned applications. The drduh guide emphasizes that App Store applications benefit from additional protections: "App Sandbox" and "Hardened Runtime" are required standards, limiting what compromised apps can access.

Disabling Gatekeeper allows arbitrary code execution without verification, significantly increasing malware risk from downloaded applications.

**Recommended settings:**
- Gatekeeper: Enabled (`assessments enabled`)

**Sources:**
- [drduh Guide - Gatekeeper and XProtect](https://github.com/drduh/macOS-Security-and-Privacy-Guide#gatekeeper-and-xprotect)
- [Apple Support - Gatekeeper](https://support.apple.com/en-us/102445)

---

### XProtect (`xprotect.sh`)

**What it checks:**
- Current XProtect malware definitions version
- Age of last XProtect update (days since installation)

**Security rationale:**
XProtect is Apple's built-in antivirus that automatically checks files against known malware signatures. While it can be bypassed by root-level exploits, it provides valuable detection for common malware families and is automatically updated by macOS. The version and age checks ensure that malware definitions are current and protecting against newly discovered threats.

Outdated XProtect definitions leave systems vulnerable to malware that has been identified and catalogued by Apple but cannot be detected without the current signature database.

**How age is determined:**
- **macOS 15+ (Sequoia)**: Uses `xprotect version` command to get precise installation timestamp
- **Older macOS**: Falls back to file modification date of XProtect.bundle
- **Pass**: Updated within last 90 days
- **Warn**: Older than 90 days or age unknown
- **Fail**: XProtect not found

**Recommended settings:**
- XProtect version: Current (regularly updated by macOS)
- Update age: Less than 90 days old

**Note:** XProtect typically updates automatically via background system updates. If the definitions are stale, check that automatic updates are enabled and the system can reach Apple's servers.

**Sources:**
- [drduh Guide - Gatekeeper and XProtect](https://github.com/drduh/macOS-Security-and-Privacy-Guide#gatekeeper-and-xprotect)
- [Apple Support - XProtect](https://support.apple.com/en-us/102445)
- [Der Flounder - Checking XProtect Update Status](https://derflounder.wordpress.com/2016/03/28/checking-xprotect-and-gatekeeper-update-status-on-macs/)
- [Using the xprotect command in macOS 15](https://macadmin.fraserhess.com/2024/09/16/using-the-xprotect-command-in-macos-15/)

---

### Software Updates (`software-update.sh`)

**What it checks:**
- Automatic update configuration
- Critical update settings
- ConfigData install settings

**Security rationale:**
Software updates patch known vulnerabilities that attackers actively exploit. The drduh guide recommends enabling automatic updates and subscribing to security announcement mailing lists to stay informed of critical patches. Delayed updates leave systems exposed to publicly disclosed vulnerabilities with available exploits.

Modern macOS separates rapid security responses (RSR) from full OS updates, allowing critical security fixes to deploy quickly without requiring major version upgrades.

**Note on modern macOS (26+):** Apple migrated to **Declarative Device Management (DDM)** for software updates. The actual settings are now stored in `/var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist` rather than the traditional `/Library/Preferences/com.apple.SoftwareUpdate.plist`. This check reads from the DDM plist on macOS 26+ and falls back to the old plist format for compatibility with older versions. As noted by [Der Flounder](https://derflounder.wordpress.com/2025/12/17/reading-ddm-managed-apple-software-update-settings-from-the-command-line-on-macos-tahoe-26-2-0/), Apple hasn't documented this change and the file format may change in future releases.

**Recommended settings:**
- `AutomaticCheckEnabled`: `1` (check automatically)
- `AutomaticDownload`: `1` (download automatically)
- `CriticalUpdateInstall`: `1` (install critical updates)
- `ConfigDataInstall`: `1` (install system data files)

**Sources:**
- [drduh Guide - Keep macOS Current](https://github.com/drduh/macOS-Security-and-Privacy-Guide#update-macos)
- [Netflix Stethoscope - Software Updates](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

### Screen Lock (`screen-lock.sh`)

**What it checks:**
- Whether screen lock on sleep/screensaver is enabled
- Screensaver idle time before activation

**Security rationale:**
Automatic screen locking prevents unauthorized access during unattended use. The drduh guide emphasizes that autologin defeats FileVault protection: "FileVault passwords act as firmware passwords preventing unauthorized boot access. Disabling autologin ensures this protection functions—unattended systems with active sessions expose data to physical attackers who don't require password entry."

Short idle timeouts balance security with usability. Enterprise environments often mandate 5-15 minute timeouts.

**Recommended settings:**
- Screen lock on sleep: Enabled
- Idle time: 300-900 seconds (5-15 minutes)

**Sources:**
- [drduh Guide - Screen Lock](https://github.com/drduh/macOS-Security-and-Privacy-Guide#screen-lock)
- [Netflix Stethoscope - Screen Lock](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

## Network & Firewall

### Firewall (`firewall.sh`)

**What it checks:**
- Application firewall global state (enabled/disabled)
- Stealth mode (prevents ICMP responses)
- Auto-whitelist for signed applications (should be disabled)

**Security rationale:**
The application layer firewall blocks incoming connections by default, preventing unauthorized network access. As the drduh guide explains: "your computer does not respond to ICMP ping requests" in stealth mode, making reconnaissance "more difficult for attackers."

**Auto-whitelist security concern:** The `--setallowsigned` feature automatically allows all code-signed applications to receive incoming connections without user notification. This is a significant security risk because:
- Attackers can use stolen or compromised developer certificates to sign malware
- Recent example: [MacSync Stealer malware](https://www.jamf.com/blog/macsync-stealer-evolution-code-signed-swift-malware-analysis/) (December 2024) was fully signed and notarized, bypassing Gatekeeper and firewall protections
- Malware with valid signatures can establish incoming connections automatically, enabling remote control

Disabling auto-whitelist requires explicit user approval for each application requesting incoming connections, following the principle of least privilege. However, many organizations enable this via MDM for usability, particularly for legitimate Apple services.

**Important limitation:** macOS firewall only blocks *incoming* connections. For outbound connection monitoring, third-party firewalls like Little Snitch or LuLu detect exfiltration attempts and command-and-control (C2) communications.

**Recommended settings:**
- Firewall state: Enabled
- Stealth mode: Enabled
- Allow signed apps: Disabled (`--setallowsigned off`)

**Sources:**
- [drduh Guide - Firewall](https://github.com/drduh/macOS-Security-and-Privacy-Guide#firewall)
- [Netflix Stethoscope - Firewall](https://github.com/Netflix-Skunkworks/stethoscope-app)
- [kristovatlas osx-config-check #16-17](https://github.com/kristovatlas/osx-config-check)

---

### Remote Login (`remote-login.sh`)

**What it checks:**
- Whether SSH (port 22), Telnet (23), SMB (445), or VNC (5900) are listening for incoming connections

**Security rationale:**
Remote access services are common attack vectors. SSH, while secure when properly configured, is frequently targeted by brute-force attacks and vulnerability exploits. The drduh guide recommends disabling SSH unless required, and if needed: "restrict to specific IPs and use key-based authentication only."

Telnet transmits credentials in plaintext and should never be enabled. SMB and VNC also present significant attack surfaces when exposed.

**Recommended settings:**
- No listening services unless explicitly required
- If SSH needed: Use key-based authentication, disable password auth, restrict by IP via firewall

**Sources:**
- [drduh Guide - Remote Access](https://github.com/drduh/macOS-Security-and-Privacy-Guide#ssh)
- [Netflix Stethoscope - Remote Login](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

### Remote Management (`remote-management.sh`)

**What it checks:**
- Apple Remote Desktop (ARD) agent status
- Remote Apple Events status
- Wake on Network Access (WOMP) setting

**Security rationale:**
Apple Remote Desktop provides complete remote control of the Mac, including screen sharing and file access. When enabled unnecessarily, it creates a privileged remote access vector. Remote Apple Events allow AppleScript execution from network sources, enabling automated attacks.

Wake on Network Access (WOMP) allows the computer to be woken remotely over the network. While convenient, it keeps network interfaces active during sleep and responds to network packets, potentially enabling attacks against sleeping systems.

**Recommended settings:**
- ARD Agent: Not running (`ard:0`)
- Remote Apple Events: Disabled (`ae:0`)
- Wake on Network: `0` (disabled for portables, optional for desktops)

**Sources:**
- [drduh Guide - Remote Management](https://github.com/drduh/macOS-Security-and-Privacy-Guide#remote-login-and-screen-sharing)
- [kristovatlas osx-config-check #30-31, #33](https://github.com/kristovatlas/osx-config-check)

---

### DNS Configuration (`dns.sh`)

**What it checks:**
- Current DNS servers configured for Wi-Fi
- Whether secure/privacy-focused DNS providers are in use (Cloudflare, Google, Quad9, Proton)

**Security rationale:**
Unencrypted DNS leaks all visited domains to ISPs and network observers, enabling surveillance and traffic analysis. The drduh guide recommends encrypted DNS (DNSCrypt/DoH) and demonstrates blocking unencrypted DNS: `"block drop quick on !lo0 proto udp from any to any port = 53"` enforces DNS through your configured resolver.

DNSSEC validation prevents DNS spoofing attacks by verifying cryptographic signatures on DNS records. Privacy-focused DNS providers (Cloudflare, Quad9, Proton) commit to not logging queries or selling data to advertisers.

**Recommended settings:**
- Use encrypted DNS resolver (DNSCrypt, DoH, or DoT)
- Choose privacy-respecting providers: Cloudflare (1.1.1.1), Quad9 (9.9.9.9), or Proton (76.76.2.0)
- Enable DNSSEC validation where available

**Sources:**
- [drduh Guide - DNS](https://github.com/drduh/macOS-Security-and-Privacy-Guide#dns)
- [kristovatlas osx-config-check #42](https://github.com/kristovatlas/osx-config-check)

---

### Bluetooth (`bluetooth.sh`)

**What it checks:**
- Bluetooth adapter state (on/off)

**Security rationale:**
Bluetooth enables proximity-based tracking and device fingerprinting. The drduh guide notes that third-party accessories don't guarantee BLE Privacy randomization, while "Apple ones...automatically be updated by your system" and support address randomization to "prevent tracking."

BlueBorne and similar Bluetooth vulnerabilities have enabled complete device compromise through wireless proximity attacks. Disabling Bluetooth when not in use eliminates this attack surface.

**Recommended settings:**
- Bluetooth: Off when not needed
- If needed: Use Apple accessories supporting BLE Privacy, clear Bluetooth metadata periodically

**Sources:**
- [drduh Guide - Bluetooth](https://github.com/drduh/macOS-Security-and-Privacy-Guide#bluetooth)
- [kristovatlas osx-config-check](https://github.com/kristovatlas/osx-config-check)

---

### Sharing Services (`sharing.sh`)

**What it checks:**
- AirDrop status
- Printer sharing status
- Internet sharing (NAT daemon) status

**Security rationale:**
Each enabled sharing service expands the attack surface. AirDrop, while convenient, has had vulnerabilities enabling unsolicited file transmission and metadata leakage. Printer sharing exposes CUPS web interface and IPP services. Internet sharing creates a NAT gateway, potentially exposing other devices through your Mac.

Following the principle of least privilege, disable all sharing services unless actively needed.

**Recommended settings:**
- AirDrop: Disabled when not in use (`DisableAirDrop: 1`)
- Printer sharing: Disabled (`0`)
- Internet sharing: Not running (`internet:0`)

**Sources:**
- [drduh Guide - Sharing Services](https://github.com/drduh/macOS-Security-and-Privacy-Guide#sharing)
- [kristovatlas osx-config-check](https://github.com/kristovatlas/osx-config-check)

---

## Privacy & Data Collection

### Siri (`siri.sh`)

**What it checks:**
- Whether Siri assistant is enabled

**Security rationale:**
The drduh guide notes that "some info is still sent to Apple when you use Siri Suggestions or Spotlight." Apple's privacy policy details transmitted data, including search queries and usage patterns. This enables behavioral profiling and personalized advertising.

The analytics database persists "even if the Siri launch agent disabled," requiring manual cleanup to prevent metadata accumulation about usage patterns. Disabling Siri prevents voice data collection and reduces data transmission to Apple servers.

**Recommended settings:**
- Siri: Disabled (`0`) for maximum privacy
- If enabled: Review Apple's data collection policies and disable suggestions/Spotlight integration

**Sources:**
- [drduh Guide - Siri](https://github.com/drduh/macOS-Security-and-Privacy-Guide#siri)

---

### Analytics (`analytics.sh`)

**What it checks:**
- Whether automatic diagnostic report submission is enabled

**Security rationale:**
Diagnostic reports contain detailed system information, crash logs, and usage patterns. Automatic submission to Apple creates a comprehensive profile of your system configuration and application usage. While Apple claims anonymization, the volume of data can enable re-identification.

Disabling automatic submission allows manual review of crash reports before submission, giving users agency over what information leaves their system.

**Recommended settings:**
- Auto-submit diagnostics: Disabled (`0`)

**Sources:**
- [drduh Guide - Analytics](https://github.com/drduh/macOS-Security-and-Privacy-Guide#analytics)

---

## Application Security

### Finder (`finder.sh`)

**What it checks:**
- Whether file extensions are shown for all files

**Security rationale:**
Hidden file extensions enable masquerading attacks where malicious applications disguise themselves. The classic example: "Evil.jpg.app" appears as an innocent image file when extensions are hidden. As the drduh guide explains: "Visible extensions provide immediate visual verification of actual file types before execution, substantially reducing social engineering effectiveness."

This is a critical defense against email attachments and downloaded files that attempt to exploit user expectations about file types.

**Recommended settings:**
- Show all extensions: Enabled (`AppleShowAllExtensions: 1`)

**Sources:**
- [drduh Guide - Miscellaneous](https://github.com/drduh/macOS-Security-and-Privacy-Guide#miscellaneous)

---

### Terminal (`terminal.sh`)

**What it checks:**
- Whether Secure Keyboard Entry is enabled in Terminal.app

**Security rationale:**
Secure Keyboard Entry prevents other applications from intercepting keyboard input during terminal sessions. This protects passwords, passphrases, and sensitive commands from keyloggers and malicious applications.

However, it conflicts with certain authentication devices (YubiKey) and text expansion utilities (TextExpander), requiring individual threat model assessment before enabling.

**Recommended settings:**
- Secure Keyboard Entry: Enabled (`1`) unless using incompatible tools

**Sources:**
- [drduh Guide - Terminal](https://github.com/drduh/macOS-Security-and-Privacy-Guide#terminal)

---

## User Account Security

### Autologin (`autologin.sh`)

**What it checks:**
- Whether automatic login is configured for any user

**Security rationale:**
The drduh guide emphasizes that autologin defeats FileVault protection: "FileVault passwords act as firmware passwords preventing unauthorized boot access. Disabling autologin ensures this protection functions—unattended systems with active sessions expose data to physical attackers who don't require password entry."

With autologin enabled, anyone with physical access can simply reboot the machine to gain full access, bypassing disk encryption entirely.

**Recommended settings:**
- Autologin: Not configured (defaults read should fail or return empty)

**Sources:**
- [drduh Guide - Users](https://github.com/drduh/macOS-Security-and-Privacy-Guide#users)

---

### User Security (`user-security.sh`)

**What it checks:**
- Current username
- User group memberships
- Guest account status

**Security rationale:**
The drduh guide recommends separate admin and standard user accounts: "Admin accounts have `sudo` access enabling system-wide compromise if exploited. Any program that the admin executes can potentially obtain the same access." Standard accounts limit privilege escalation attack surface.

Guest accounts provide unauthenticated access to the system, creating an anonymous entry point. Disabling guest accounts prevents unauthorized usage and eliminates a privilege escalation vector.

**Recommended settings:**
- Use separate admin/standard accounts for daily work
- Guest account: Disabled (`GuestEnabled: 0`)
- Minimize group memberships (principle of least privilege)

**Sources:**
- [drduh Guide - Users](https://github.com/drduh/macOS-Security-and-Privacy-Guide#users)

---


## Developer Tools

### Homebrew (`homebrew.sh`)

**What it checks:**
- Whether Homebrew is installed
- Homebrew bin directory position in PATH
- Analytics opt-out status

**Security rationale:**
Homebrew is a popular package manager, but introduces security considerations. PATH positioning matters because attackers can exploit PATH precedence to shadow system utilities with malicious versions. Homebrew's `/usr/local/bin` or `/opt/homebrew/bin` should come before `/usr/bin` only if you consciously want Homebrew packages to override system utilities.

Homebrew analytics collects installation data and usage patterns. While claimed to be anonymized, opting out prevents telemetry transmission.

**Recommended settings:**
- PATH: Consider whether Homebrew should override system utilities (depends on use case)
- Analytics: Disabled (`analytics:0`)

**Sources:**
- [kristovatlas osx-config-check #1-2, #13](https://github.com/kristovatlas/osx-config-check)

---

### Development Tools (`dev-tools.sh`)

**What it checks:**
Versions of common development tools against minimum safe versions:
- Git (CVE-2024-32002 and others)
- Curl (CVE-2024-0853 and others)
- OpenSSL (multiple CVE fixes)

**Security rationale:**
Development tools are privileged attack surfaces. Git vulnerabilities have enabled arbitrary code execution during clone/checkout operations. Curl vulnerabilities expose applications to exploitation when fetching remote content. OpenSSL vulnerabilities affect TLS/SSL implementations across the system.

Outdated development tools create supply chain risks: compromised repositories or man-in-the-middle attacks can exploit known vulnerabilities in older tool versions to compromise the development environment and inject malicious code into projects.

**Recommended settings:**
- Git: ≥ 2.45.0 (CVE-2024-32002 fix)
- Curl: ≥ 8.6.0 (CVE-2024-0853 fix)
- OpenSSL: ≥ 3.2.0 (multiple CVE fixes)
- Update regularly via Homebrew or system updates

**Sources:**
- [kristovatlas osx-config-check #19, #40, #43](https://github.com/kristovatlas/osx-config-check)

---

### GPG Mail & Proton Security Tools (`gpgmail.sh`)

**What it checks:**
- GPGMail installation and encryption/signing defaults
- Proton Mail, Proton Pass, and ProtonVPN installation

**Security rationale:**
Email encryption protects message confidentiality and integrity. GPGMail integrates OpenPGP into Apple Mail, enabling end-to-end encryption. Default encryption/signing ensures consistent security rather than requiring manual activation per message.

Proton services provide privacy-focused alternatives:
- **Proton Mail:** End-to-end encrypted email in zero-knowledge architecture
- **Proton Pass:** Encrypted password manager (alternative to cloud-synced managers)
- **ProtonVPN:** Privacy-focused VPN with no-logging policy

**Recommended settings:**
- If using GPGMail: Enable default encryption and signing
- Consider Proton services for privacy-critical communications

**Sources:**
- [drduh Guide - PGP/GPG](https://github.com/drduh/macOS-Security-and-Privacy-Guide#pgpgpg)
- [kristovatlas osx-config-check #78-82](https://github.com/kristovatlas/osx-config-check)

---

## MDM & Enterprise

### Configuration Profiles (`profiles.sh`)

**What it checks:**
- MDM enrollment status
- Number of installed configuration profiles

**Security rationale:**
Mobile Device Management (MDM) profiles provide centralized security policy enforcement in enterprise environments. They can enforce security settings that users cannot modify, ensuring consistent security posture across managed devices.

However, MDM also grants significant control to the enrolling organization, including:
- Remote wipe capability
- Application installation/removal
- Network traffic inspection
- Location tracking
- Restriction of system settings

Personal devices should carefully evaluate MDM enrollment implications. Enterprise-managed devices should verify legitimate organizational enrollment and review applied policies.

**Informational check:**
- Reports enrollment status and profile count
- Review profiles in System Settings > Privacy & Security > Profiles

**Sources:**
- [Apple Deployment Guide - MDM Profiles](https://support.apple.com/guide/deployment/intro-to-mdm-profiles-depc0aadd3fe/web)

---

## System Information

### Operating System (`os.sh`)

**What it checks:**
- Product name (macOS)
- Product version (e.g., 14.2)
- Build version

**Security rationale:**
OS version information is essential for vulnerability assessment. Each macOS version has known security issues, and older versions no longer receive security updates. The drduh guide recommends keeping macOS current: "Patches known vulnerabilities that attackers actively exploit."

Apple typically supports the current macOS version and previous two versions with security updates. Running unsupported versions leaves systems exposed to publicly disclosed vulnerabilities without available patches.

**Informational check:**
- Verify you're running a supported macOS version
- Cross-reference against Apple security updates: https://support.apple.com/HT201222

**Sources:**
- [drduh Guide - Keep macOS Current](https://github.com/drduh/macOS-Security-and-Privacy-Guide#update-macos)
- [Netflix Stethoscope - OS](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

### Hardware Information (`hardware.sh`)

**What it checks:**
- Model Identifier
- Serial Number
- Hardware UUID

**Security rationale:**
Hardware information is essential for:
- **Asset management:** Tracking device inventory in enterprise environments
- **Vulnerability assessment:** Certain hardware models have specific vulnerabilities (e.g., Thunderbolt DMA attacks on pre-T2 Macs)
- **Firmware verification:** T2/Apple Silicon Macs provide hardware-verified secure boot
- **Theft recovery:** Serial numbers identify stolen devices

Modern Apple Silicon and T2 Macs provide significant security improvements over earlier Intel Macs:
- Hardware-verified secure boot chain
- Hardware-backed encryption keys
- DMA protection via IOMMU
- Separate security processor

**Informational check:**
- Identifies hardware for security capability assessment
- No pass/fail criteria

**Sources:**
- [Netflix Stethoscope - Hardware](https://github.com/Netflix-Skunkworks/stethoscope-app)

---

## Closing thoughts

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
