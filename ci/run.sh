#!/usr/bin/env bash
set -euo pipefail

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"
source ${YP_DIR}/ci/util/env.inc.sh

[[ "${1:-}" != "debug" ]] || {
    ${YP_DIR}/bin/ci-debug
    exit 0
}

# pipeline
source ${YP_DIR}/ci/before-install.inc.sh
source ${YP_DIR}/ci/install.inc.sh
# source ${YP_DIR}/ci/before-script.inc.sh
source ${YP_DIR}/ci/script.inc.sh
source ${YP_DIR}/ci/before-cache.inc.sh
# source ${YP_DIR}/ci/after-success.inc.sh
# source ${YP_DIR}/ci/after-failure.inc.sh
source ${YP_DIR}/ci/before-deploy.inc.sh
# source ${YP_DIR}/ci/deploy.inc.sh
# source ${YP_DIR}/ci/after-deploy.inc.sh
source ${YP_DIR}/ci/after-script.inc.sh
source ${YP_DIR}/ci/notifications.inc.sh


function yp_ci_run() {
    >&2 echo "$(date +"%H:%M:%S") [DO  ] $*"

    CMD=
    if [[ "$(type -t "ci_run_${1}" || true)" = "function" ]]; then
        CMD="ci_run_${1}"
    elif [[ "$(type -t "yp_ci_run_${1}" || true)" = "function" ]]; then
        CMD="yp_ci_run_${1}"
    else
        >&2 echo "$(date +"%H:%M:%S") [INFO] Couldn't find a ci_run_${1} or yp_ci_run_${1} function."

        >&2 echo "$(date +"%H:%M:%S") [DONE] $*"
        return 0
    fi

    [[ "${TRAVIS:-}" != "true" ]] || {
        if [[ -f /yplatform.docker-ci ]]; then
            echo_info "Running inside the yp-docker-ci container."
        elif [[ "${OS_SHORT:-}" != "linux" ]]; then
            echo_info "Skipping the yp-docker-ci container because the host OS is not linux."
        elif ${YP_DIR}/bin/is-wsl; then
            echo_info "Skipping the yp-docker-ci container because the host OS is Windows Subsystem for Linux."
        elif [[ "${YP_DOCKER_CI_IMAGE:-}" = "false" ]]; then
            echo_info "Skipping the yp-docker-ci container because YP_DOCKER_CI_IMAGE=false."
        else
            local RUN_IN_YP_DOCKER_CI="docker exec -it -w ${TRAVIS_BUILD_DIR} -u $(id -u):$(id -g) yp-docker-ci-travis"
            CMD="${RUN_IN_YP_DOCKER_CI} ${0} $* 2>&1"
            # use unbuffer and pv to minimize risk of travis getting jammed due to log-processing quirks
            CMD="unbuffer ${CMD} | pv -q -L 3k"

            [[ "${1}" != "before_install" ]] || {
                yp_run_docker_ci_in_travis

                # /home/travis is not readable by others, like the yp:yp user which will do the bootstrapping
                ${RUN_IN_YP_DOCKER_CI} ${YP_DIR}/bin/linux-adduser2group yp travis
            }
        fi

        [[ "${1}" != "before_install" ]] || {
            [[ -f /yplatform.docker-ci ]] || yp_enable_travis_swap
        }
    }

    # print out the command before running it
    echo "$(pwd)\$ ${CMD}"

    eval "${CMD}"

    >&2 echo "$(date +"%H:%M:%S") [DONE] $*"
}

[[ -z "$*" ]] || yp_ci_run "$@"
