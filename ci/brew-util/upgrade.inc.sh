#!/usr/bin/env bash
set -euo pipefail

function brew_upgrade_one() {
    local FORMULA="$@"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")

    # install any missing dependencies
    local MISSING="$(brew missing ${NAME})"
    [[ -z "${MISSING}" ]] || {
        echo_info "brew: Found missing dependencies for ${NAME}: ${MISSING}."
        echo_do "brew: Installing missing dependencies for ${NAME}..."
        brew install ${MISSING}
        echo_done
    }

    # link, if not already
    echo_do "brew: Linking ${NAME}..."
    if [[ "${CI:-}" != "true" ]]; then
        brew link ${NAME} || true
    else
        brew link --force --overwrite ${NAME} || true
    fi
    echo_done

    # is it pinned?
    if brew list ${NAME} --pinned | grep -q "^${NAME}$"; then
        echo_info "brew: ${NAME} is pinned."
        echo_skip "brew: Upgrading ${NAME}..."
        return 0
    fi

    # is it already up-to-date?
    if ! brew outdated ${NAME} >/dev/null 2>&1; then
        echo_info "brew: ${NAME} is up-to-date."
        echo_skip "brew: Upgrading ${NAME}..."
        return 0
    fi

    echo_do "brew: Upgrading ${NAME}..."
    # FIXME needs to handle patched formulas
    brew upgrade ${NAME}
    echo_done
}

function brew_upgrade() {
    while read -u3 FORMULA; do
        [[ -n "${FORMULA}" ]] || continue
        brew_upgrade_one "${FORMULA}"
    done 3< <(echo "$@")
}
