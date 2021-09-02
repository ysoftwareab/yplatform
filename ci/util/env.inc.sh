#!/usr/bin/env bash

# fix $HOME
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/home.inc.sh

# detect CI platform
for SF_CI_ENV in ${SUPPORT_FIRECLOUD_DIR}/ci/env/*.inc.sh; do
    source ${SF_CI_ENV}
done
unset SF_CI_ENV
for SF_CI_ENV_FUN in $(declare -F | grep --only-matching "\bsf_ci_env_.*"); do
    "${SF_CI_ENV_FUN}"
    [[ -z "${SF_CI_PLATFORM:-}" ]] || break
done
unset SF_CI_ENV_FUN

[[ -z "${SF_CI_PLATFORM:-}" ]] || eval "export $(sf_ci_known_env_sf | tr "\n" " ")"

# set git user
if command -v git >/dev/null 2>&1; then
    [[ -z "${SF_CI_PLATFORM:-}" ]] || [[ -z "${SF_CI_SERVER_HOST:-}" ]] || \
        git config --global user.email "${SF_CI_PLATFORM}@${SF_CI_SERVER_HOST}"
    [[ -z "${SF_CI_NAME:-}" ]] || \
        git config --global user.name "${SF_CI_NAME}"
fi

# common env
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

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

# CONST.inc{,.secret} env
set -a
# shellcheck disable=SC1091
[[ ! -f ${GIT_ROOT}/CONST.inc ]] || source ${GIT_ROOT}/CONST.inc
if git config --local transcrypt.version >/dev/null; then
    # shellcheck disable=SC1091
    [[ ! -f ${GIT_ROOT}/CONST.inc.secret ]] || source ${GIT_ROOT}/CONST.inc.secret
fi
set +a

# util functions
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/debug.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/docker-ci.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/travis-docker.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/travis-swap.inc.sh
