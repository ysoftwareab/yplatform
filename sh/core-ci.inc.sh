#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# HOME is always set incorrectly to /github/home, even in containers
# see https://github.com/actions/runner/issues/863
HOME_REAL=$(eval echo "~$(id -u -n)")
[[ "${HOME}" = "${HOME_REAL}" ]] || {
    >&2 echo "[WARN] \$HOME was ${HOME}. It is now reset to ${HOME_REAL}."
    export HOME="${HOME_REAL}"

    # NOTE ideally we would unset all current variables,
    # but we need to detect and retain those set in the CI configuration
    # e.g. not only GITHUB_*, but also any given in "env:" as part of a workflow
    # so instead we only update current variables
    eval "$(env -i HOME="${HOME}" bash -l -c "printenv" | sed "s/^/export /")"
}
unset HOME_REAL

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
