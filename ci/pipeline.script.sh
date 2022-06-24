#!/usr/bin/env bash
set -euo pipefail

after_script() {
    EXIT_STATUS=$?
    [[ "${EXIT_STATUS}" = "0" ]] || export YP_CI_STATUS=failure
    ./.ci.sh after_script
    exit ${EXIT_STATUS}
}
trap after_script EXIT

function success_pipeline() {
    ./.ci.sh before_install
    ./.ci.sh install
    ./.ci.sh before_script
    ./.ci.sh script
    ./.ci.sh before_cache || true
    ./.ci.sh after_success || true
}

function failure_pipeline() {
    ./.ci.sh after_failure || true
}

export YP_CI_STATUS=success
success_pipeline || {
    export YP_CI_STATUS=failure
    failure_pipeline
    exit 1
}
