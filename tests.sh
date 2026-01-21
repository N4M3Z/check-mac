#!/bin/bash
DIR="$(dirname "$0")/tests"
GREEN='\033[0;32m' RED='\033[0;31m' N='\033[0m'
pass=0 fail=0

for test in "$DIR"/test-*.sh; do
    name=$(basename "$test" .sh | sed 's/test-//')
    printf "%-20s" "$name"
    result=$("$test" 2>/dev/null)
    if [[ "$result" == "PASS" ]]; then
        echo -e "${G}PASS${N}"; ((pass++))
    else
        echo -e "${R}FAIL${N}"; ((fail++))
    fi
done

echo ""
echo -e "Results: ${GREEN}$pass passed${N}, ${RED}$fail failed${N}"
exit $fail
