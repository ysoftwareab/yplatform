#!/usr/bin/env bash
set -euo pipefail

after_script() {
    EXIT_STATUS=$?
    [[ "${EXIT_STATUS}" = "0" ]] || export YP_CI_STATUS=failure
    ./.ci.sh after_script
    exit ${EXIT_STATUS}
}
trap after_script EXIT

function fail_pipeline() {
    export YP_CI_STATUS=failure
    ./.ci.sh after_failure || true
    exit 1
}

export YP_CI_STATUS=success
./.ci.sh before_install || fail_pipeline
./.ci.sh install || fail_pipeline
./.ci.sh before_script || fail_pipeline
./.ci.sh script || fail_pipeline
./.ci.sh before_cache || true
./.ci.sh after_success || true
