#!/usr/bin/env bash
set -euo pipefail

after_script() {
    EXIT_STATUS=$?
    ./.ci.sh after_script
    exit ${EXIT_STATUS}
}
trap after_script EXIT

SF_CI_STATUS=success
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh before_install || SF_CI_STATUS=failure
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh install || SF_CI_STATUS=failure
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh before_script || SF_CI_STATUS=failure
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh script || SF_CI_STATUS=failure
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh before_cache || true
[[ "${SF_CI_STATUS}" != "success" ]] || ./.ci.sh after_success || true
[[ "${SF_CI_STATUS}" != "failure" ]] || ./.ci.sh after_failure || true
