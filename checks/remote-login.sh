#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/remote-login.sh

# Retrieve listening ports
listening_ports=$(
    netstat -an 2>/dev/null | grep -E '\.(22|23|445|5900)[[:space:]].*LISTEN'
)

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_ssh=$OK
pass_telnet=$OK
pass_file_share=$OK
pass_screen_share=$OK

[[ "$listening_ports" =~ \.22[[:space:]] ]] && pass_ssh=$WARN
[[ "$listening_ports" =~ \.23[[:space:]] ]] && pass_telnet=$WARN
[[ "$listening_ports" =~ \.445[[:space:]] ]] && pass_file_share=$WARN
[[ "$listening_ports" =~ \.5900[[:space:]] ]] && pass_screen_share=$WARN

# Output
echo "pass_ssh:$pass_ssh"
echo "pass_telnet:$pass_telnet"
echo "pass_file_share:$pass_file_share"
echo "pass_screen_share:$pass_screen_share"
