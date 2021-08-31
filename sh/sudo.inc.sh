#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function sf_nosudo() {
    echo "[ERR ] sudo required, but not available for running the following command:"
    echo "       $*"
    prompt_q_to_continue "Run the command yourself as root, then continue."
}
export -f sf_nosudo

if printenv | grep -q "^SF_SUDO="; then
    # Don't change if already set and exported.
    # NOTE 'test -v SF_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    # NOTE 'test -v SF_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    true
else
    SF_SUDO="$(command -v sudo 2>/dev/null || true)"
    if [[ -z "${SF_SUDO}" ]]; then
        if [[ "${EUID}" = "0" ]]; then
            # Root user doesn't need sudo.
            true
        else
            # The user has no sudo installed.
            SF_SUDO=sf_nosudo_fallback
            function sf_nosudo_fallback() {
                sf_nosudo "$@"
            }
            export -f sf_nosudo_fallback
        fi
    fi
    export SF_SUDO
fi
