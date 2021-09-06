#!/usr/bin/env bash
set -euo pipefail

# CIs have issues keeping stdout and stderr in sync because they parse the streams
# e.g. to mask secret values
exec 2>&1

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/ci/util/env.inc.sh

# debug
[[ "${1:-}" != "debug" ]] || {
    echo
    echo "[INFO] You can run specific stages like"
    echo "       ./.ci.sh before_install"
    echo "       or you can run them all (before_install, install, before_script, script)"
    echo "       ./.ci.sh all"
    echo
    export SF_CI_DEBUG_MODE=true

    # export all functions $(e.g. nvm)
    source <(declare -F | sed "s/^declare /export /g")

    # PS1="${debian_chroot:+($debian_chroot)}\u\w\$ " bash
    PS1="\w\$ " bash
    exit 0
}

# pipeline
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

[[ -z "$*" ]] || sf_ci_run "$@"
