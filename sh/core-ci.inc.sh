#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# HOME is always set incorrectly to /github/home, even in containers
# see https://github.com/actions/runner/issues/863
HOME_REAL=$(eval echo "~$(id -u -n)")
[[ "${HOME}" = "${HOME_REAL}" ]] || {
    >&2 echo "$(date +"%H:%M:%S") [WARN] \$HOME is overriden to ${HOME}."
    >&2 echo "$(date +"%H:%M:%S") [DO  ] Resetting \$HOME to ${HOME_REAL}..."

    TMP_ENV=$(mktemp)
    printenv >${TMP_ENV}

    export HOME="${HOME_REAL}"

    # NOTE ideally we would unset all current variables,
    # but we need to detect and retain those set in the CI configuration
    # e.g. not only GITHUB_*, but also any given in "env:" as part of a workflow
    # so instead we only update current variables
    # NOTE this doesn't update exported functions
    eval "$(env -i HOME="${HOME}" bash -l -i -c "printenv" | \
        sed "s/'/\\\\'/g" | \
        sed "s/^\([^=]\+\)=\(.*\)$/export \1='\2'/g")"

    >&2 echo "$(date +"%H:%M:%S") [INFO] Setting the following environment variables:"
    >&2 grep -Fx -v -f ${TMP_ENV} <(printenv | sort) | grep "^<" || true
    rm -f ${TMP_ENV}

    >&2 echo "$(date +"%H:%M:%S") [DONE]"
}
unset HOME_REAL

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
