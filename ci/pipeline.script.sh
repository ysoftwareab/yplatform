#!/usr/bin/env bash
set -euo pipefail

after_script() {
    EXIT_STATUS=$?
    ./.ci.sh after_script
    exit ${EXIT_STATUS}
}
trap after_script EXIT

YP_CI_STATUS=success
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh before_install || YP_CI_STATUS=failure
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh install || YP_CI_STATUS=failure
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh before_script || YP_CI_STATUS=failure
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh script || YP_CI_STATUS=failure
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh before_cache || true
[[ "${YP_CI_STATUS}" = "failure" ]] || ./.ci.sh after_success || true
[[ "${YP_CI_STATUS}" = "success" ]] || ./.ci.sh after_failure || true
[[ "${YP_CI_STATUS}" = "success" ]] || exit 1
