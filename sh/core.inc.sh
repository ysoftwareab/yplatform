#!/usr/bin/env bash
set -euo pipefail

CI=${CI:-}
[[ "${CI}" != "1" ]] || CI=true

V=${V:-${VERBOSE:-}}
VERBOSE=${V}
[[ "${VERBOSE}" != "1" ]] || VERBOSE=true

# [[ "${CI}" != "true" ]] || {
#     # VERBOSE=true
# }

[[ ${VERBOSE} != true ]] || set -x

if [[ "${EUID}" = "0" ]]; then
    # Root user doesn't need sudo.
    export SUDO=
elif printenv | grep -q "^SUDO="; then
    # Don't change if already set.
    # NOTE 'test -v SUDO' is only available in bash 4.2, but this script may run in bash 3+
    true
else
    SUDO="$(which sudo)"
    SUDO="${SUDO:-sf_nosudo}"
    export SUDO
fi

if [[ "${SUDO}" = "sf_nosudo" ]]; then
    # The user has exported SUDO= or has no sudo installed.
    function sf_nosudo() {
        echo "[ERR ] sudo required, but not available for running the following command:"
        echo "       $@"
        echo "[Q   ] Run the command yourself as root, then continue."
        echo "       Press ENTER to Continue."
        echo "       Press Ctrl-C to Cancel."
        read -p ""
        echo
    }
    export -f sf_nosudo
fi

ARCH=$(uname -m)
ARCH_BIT=$(uname -m | grep -q "x86_64" && echo "64" || echo "32")
ARCH_SHORT=$(uname -m | grep -q "x86_64" && echo "x64" || echo "x86")
OS=$(uname | tr "[A-Z]" "[a-z]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([a-z]\+\).*/\1/g")

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_BRANCH_SHORT=$(basename ${GIT_BRANCH} 2>/dev/null || true)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null || true)
GIT_REMOTE=$(git config branch.${GIT_BRANCH}.remote 2>/dev/null || true)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
GIT_TAGS=$(git describe --exact-match --tags HEAD 2>/dev/null || true)

[[ "${CI}" != "true" ]] || {
    [[ -z "${TRAVIS_BRANCH:-}" ]] || {
        GIT_BRANCH=${TRAVIS_BRANCH}
        GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
    }
}
