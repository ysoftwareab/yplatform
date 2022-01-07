#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_nosudo() {
    >&2 echo "$(date +"%H:%M:%S")" "[ERR ] sudo required, but not available for running the following command:"
    >&2 echo "                $*"
    prompt_q_to_continue "Run the command yourself as root, then continue."
}
export -f yp_nosudo

if printenv | grep -q "^YP_SUDO="; then
    # Don't change if already set and exported.
    # NOTE 'test -v YP_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    # NOTE 'test -v YP_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    true
else
    YP_SUDO="$(command -v sudo 2>/dev/null || true)"
    if [[ -z "${YP_SUDO}" ]]; then
        if [[ "${EUID}" = "0" ]]; then
            # Root user doesn't need sudo.
            true
        else
            # The user has no sudo installed.
            YP_SUDO=yp_nosudo_fallback
            function yp_nosudo_fallback() {
                yp_nosudo "$@"
            }
            export -f yp_nosudo_fallback
        fi
    fi
    export YP_SUDO
fi
