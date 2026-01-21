#!/bin/bash
# Source: stethoscope-app/src/sources/darwin/screen-lock.sh

# Retrieve values
screenlock_status=$(
    sysadminctl -screenLock status 2>&1
)
idle_time=$(
    defaults -currentHost read com.apple.screensaver idleTime 2>/dev/null
)

# Apply defaults
idle_time=${idle_time:-0}

# Test logic (Nagios exit codes)
OK=0; WARN=1; CRIT=2; INFO=3

pass_password_on_wake=$CRIT
pass_screen_timeout=$INFO

[[ "$screenlock_status" == *"delay is"* ]] && pass_password_on_wake=$OK

if [[ $idle_time =~ ^[0-9]+$ ]] && [[ $idle_time -gt 0 ]]; then
    if [[ $idle_time -le 300 ]]; then
        pass_screen_timeout=$OK
    else
        pass_screen_timeout=$WARN
    fi
fi

# Output (include idle_time value for check.sh to display)
echo "idle_time:$idle_time"
echo "pass_password_on_wake:$pass_password_on_wake"
echo "pass_screen_timeout:$pass_screen_timeout"
