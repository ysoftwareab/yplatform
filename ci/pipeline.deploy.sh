#!/usr/bin/env bash
set -euo pipefail

# don't deploy from PRs ever
[[ "${YP_CI_IS_PR}" != "true" ]] || exit 0

function fail_pipeline() {
    export YP_CI_STATUS=failure
    exit 1
}

export YP_CI_STATUS=success
./.ci.sh before_deploy || fail_pipeline
./.ci.sh deploy || fail_pipeline
./.ci.sh after_deploy || fail_pipeline
