#!/bin/bash
# Source: kristovatlas/osx-config-check (CHECK #19, #40, #43)

# Minimum safe versions
MIN_GIT="2.45.0"
MIN_CURL="8.6.0"
MIN_OPENSSL="3.2.0"

version_gte() {
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

# Retrieve versions (guarded so probes never provoke the Xcode CLT GUI installer
# on a fresh Mac; an absent CLI is reported as "none", never as a forced install)
git_version=""
if command -v git >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; then
    git_version=$(
        git --version 2>/dev/null | awk '{print $3}'
    )
fi
curl_version=""
if command -v curl >/dev/null 2>&1; then
    curl_version=$(
        curl --version 2>/dev/null | head -1 | awk '{print $2}'
    )
fi
openssl_version=""
if command -v openssl >/dev/null 2>&1; then
    openssl_version=$(
        openssl version 2>/dev/null | awk '{print $2}'
    )
fi

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_git=$INFO
pass_curl=$INFO
pass_openssl=$INFO

if [[ -n "$git_version" ]]; then
    version_gte "$git_version" "$MIN_GIT" && pass_git=$OK || pass_git=$WARN
fi

if [[ -n "$curl_version" ]]; then
    version_gte "$curl_version" "$MIN_CURL" && pass_curl=$OK || pass_curl=$WARN
fi

if [[ -n "$openssl_version" ]]; then
    version_gte "$openssl_version" "$MIN_OPENSSL" && pass_openssl=$OK || pass_openssl=$WARN
fi

# Output (include versions for check.sh to display)
echo "git_version:${git_version:-none}"
echo "curl_version:${curl_version:-none}"
echo "openssl_version:${openssl_version:-none}"
echo "pass_git:$pass_git"
echo "pass_curl:$pass_curl"
echo "pass_openssl:$pass_openssl"
