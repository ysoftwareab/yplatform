#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# HOME is always set incorrectly to /github/home, even in containers
# see https://github.com/actions/runner/issues/863
HOME_REAL=$(eval echo "~$(id -u -n)")
[[ "${HOME}" = "${HOME_REAL}" ]] || {
    >&2 echo "[WARN] \$HOME was ${HOME}. It is now reset to ${HOME_REAL}."
    export HOME="${HOME_REAL}"
}
unset HOME_REAL

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
