#!/bin/bash
# Source: https://support.apple.com/guide/deployment/intro-to-mdm-profiles-depc0aadd3fe/web

# Retrieve values
mdm_status=$(
    profiles status -type enrollment 2>/dev/null
)

# Check MDM enrollment status
mdm_enrolled=0
[[ "$mdm_status" == *"MDM enrollment: Yes"* ]] && mdm_enrolled=1

# Output
echo "mdm_enrolled:$mdm_enrolled"
