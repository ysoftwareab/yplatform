#!/usr/bin/env bash

# CIs have issues keeping stdout and stderr in sync because they parse the streams
# e.g. to mask secret values
exec 2>&1

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

if command -v git >/dev/null 2>&1; then
    GIT_COMMIT_MSG=$(git log -1 --format="%B")
    if echo "${GIT_COMMIT_MSG}" | grep -q "\[skip ci\]"; then
        echo_info "Detected '[skip ci]' marker in git commit message."
        echo_skip "$*"
        exit 0
    fi

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
fi

set -a
# shellcheck disable=SC1091
[[ ! -f ${GIT_ROOT}/CONST.inc ]] || source ${GIT_ROOT}/CONST.inc
if git config --local transcrypt.version >/dev/null; then
    # shellcheck disable=SC1091
    [[ ! -f ${GIT_ROOT}/CONST.inc.secret ]] || source ${GIT_ROOT}/CONST.inc.secret
fi
set +a

source ${SUPPORT_FIRECLOUD_DIR}/ci/debug.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/ci/run.docker-ci.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/run.travis-docker.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/run.travis-swap.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/ci/before-install.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/install.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/ci/before-script.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/script.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/before-cache.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/ci/after-success.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/ci/after-failure.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/before-deploy.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/ci/deploy.inc.sh
# source ${SUPPORT_FIRECLOUD_DIR}/ci/after-deploy.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/ci/after-script.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/ci/notifications.inc.sh


function sf_ci_run() {
    >&2 echo "$(date +"%H:%M:%S") [DO  ] $*"

    CMD=
    if [[ "$(type -t "ci_run_${1}" || true)" = "function" ]]; then
        CMD="ci_run_${1}"
    elif [[ "$(type -t "sf_ci_run_${1}" || true)" = "function" ]]; then
        CMD="sf_ci_run_${1}"
    else
        >&2 echo "$(date +"%H:%M:%S") [INFO] Couldn't find a ci_run_${1} or sf_ci_run_${1} function."

        >&2 echo "$(date +"%H:%M:%S") [DONE] $*"
        return 0
    fi

    [[ "${TRAVIS:-}" != "true" ]] || {
        if [[ -f /support-firecloud.docker-ci ]]; then
            echo_info "Running inside the sf-docker-ci container."
        elif [[ "${OS_SHORT:-}" != "linux" ]]; then
            echo_info "Skipping the sf-docker-ci container because the host OS is not linux."
        elif ${SUPPORT_FIRECLOUD_DIR}/bin/is-wsl; then
            echo_info "Skipping the sf-docker-ci container because the host OS is Windows Subsystem for Linux."
        elif [[ "${SF_DOCKER_CI_IMAGE:-}" = "false" ]]; then
            echo_info "Skipping the sf-docker-ci container because SF_DOCKER_CI_IMAGE=false."
        else
            local RUN_IN_SF_DOCKER_CI="docker exec -it -w ${TRAVIS_BUILD_DIR} -u $(id -u):$(id -g) sf-docker-ci-travis"
            CMD="${RUN_IN_SF_DOCKER_CI} ${0} $* 2>&1"
            # use unbuffer and pv to minimize risk of travis getting jammed due to log-processing quirks
            CMD="unbuffer ${CMD} | pv -q -L 3k"

            [[ "${1}" != "before_install" ]] || {
                sf_run_docker_ci_in_travis

                # /home/travis is not readable by others, like the sf:sf user which will do the bootstrapping
                ${RUN_IN_SF_DOCKER_CI} ${SUPPORT_FIRECLOUD_DIR}/bin/linux-adduser2group sf travis
            }
        fi

        [[ "${1}" != "before_install" ]] || {
            [[ -f /support-firecloud.docker-ci ]] || sf_enable_travis_swap
        }
    }

    # print out the command before running it
    echo "$(pwd)\$ ${CMD}"

    eval "${CMD}"

    >&2 echo "$(date +"%H:%M:%S") [DONE] $*"
}

for SF_CI_ENV in ${SUPPORT_FIRECLOUD_DIR}/ci/env/*.inc.sh; do
    source ${SF_CI_ENV}
done
unset SF_CI_ENV
for SF_CI_ENV_FUN in $(declare -F | grep --only-matching "\bsf_ci_env_.*"); do
    "${SF_CI_ENV_FUN}"
done
unset SF_CI_ENV_FUN

[[ -z "${SF_CI_PLATFORM:-}" ]] || [[ -z "${SF_CI_SERVER_HOST:-}" ]] || \
    git config --global user.email "${SF_CI_PLATFORM}@${SF_CI_SERVER_HOST}"
[[ -z "${SF_CI_NAME:-}" ]] || \
    git config --global user.name "${SF_CI_NAME}"

[[ -z "$*" ]] || sf_ci_run "$@"
