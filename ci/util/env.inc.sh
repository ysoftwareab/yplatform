#!/usr/bin/env bash
set -euo pipefail

# fix $HOME
source ${YP_DIR}/ci/util/home.inc.sh

# detect CI platform
for YP_CI_ENV in ${YP_DIR}/ci/env/*.inc.sh; do
    source ${YP_CI_ENV}
done
unset YP_CI_ENV
for YP_CI_ENV_FUN in $(declare -F | grep --only-matching "\byp_ci_env_.*"); do
    "${YP_CI_ENV_FUN}"
    [[ -z "${YP_CI_PLATFORM:-}" ]] || break
done
unset YP_CI_ENV_FUN

[[ -z "${YP_CI_PLATFORM:-}" ]] || eval "export $(yp_ci_known_env_yp | tr "\n" " ")"

# set git
[[ -z "${YP_CI_NAME:-}" ]] || {
    # shellcheck disable=SC2034
    GIT_USER_NAME="${YP_CI_NAME}"
}
[[ -z "${YP_CI_PLATFORM:-}" ]] || [[ -z "${YP_CI_SERVER_HOST:-}" ]] || {
    # shellcheck disable=SC2034
    GIT_USER_EMAIL="${YP_CI_PLATFORM}@${YP_CI_SERVER_HOST}"
}
source ${YP_DIR}/ci/util/gitconfig.inc.sh

# common env
source ${YP_DIR}/sh/common.inc.sh

# skip from commit message
if echo "${GIT_COMMIT_MSG}" | grep -q "\[skip ci\]"; then
    echo_info "Detected '[skip ci]' marker in git commit message."
    echo_skip "$*"
    exit 0
fi

# env from commit message
if echo "${GIT_COMMIT_MSG}" | grep -q "\[env [^=]\+=[^]]\+\]"; then
    echo_info "Detected '[env key=value]' marker in git commit message."
    echo "${GIT_COMMIT_MSG}" | \
        grep --only-matching "\[env [^=]\+=[^]]\+\]" | \
        sed "s/^\[env /export /g" | \
        sed "s/\]\$//g" | while read -r EXPORT_KV; do
        echo_info "${EXPORT_KV}"
        eval "${EXPORT_KV}"
    done
    unset EXPORT_KV
fi

# util functions
source ${YP_DIR}/ci/util/debug.inc.sh
source ${YP_DIR}/ci/util/docker-ci.inc.sh
[[ "${YP_CI_PLATFROM:-}" != "travis" ]] || {
    source ${YP_DIR}/ci/util/travis-docker.inc.sh
    source ${YP_DIR}/ci/util/travis-swap.inc.sh
}
