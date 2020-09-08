#!/usr/bin/env bash
set -euo pipefail

function brew_upgrade() {
    while read -u3 FORMULA; do
        [[ -n "${FORMULA}" ]] || continue
        brew_upgrade_one "${FORMULA}"
    done 3< <(echo "$@")
}
