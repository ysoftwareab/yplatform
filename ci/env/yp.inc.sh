#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_yp() {
    true
}

function yp_ci_printvars_yp() {
    printenv_all | sort -u | grep \
        -e "^CI=" \
        -e "^YP_CI_"
}

function yp_ci_known_env_yp() {
    # keep in sync with ci/README.md
    cat <<EOF | sort -u | grep -v -e "^$" -e "^#"
# core
CI
YP_CI_NAME
YP_CI_PLATFORM
YP_CI_SERVER_HOST
YP_CI_REPO_SLUG
YP_CI_ROOT

# is
YP_CI_IS_CRON
YP_CI_IS_PR

# job/pipeline
YP_CI_JOB_ID
YP_CI_PIPELINE_ID
YP_CI_JOB_URL
YP_CI_PIPELINE_URL

# pr
YP_CI_PR_NUMBER
YP_CI_PR_URL
YP_CI_PR_REPO_SLUG
YP_CI_PR_GIT_HASH
YP_CI_PR_GIT_BRANCH

# git
YP_CI_GIT_HASH
YP_CI_GIT_BRANCH
YP_CI_GIT_TAG

# misc
YP_CI_DEBUG_MODE
YP_CI_PHASE
YP_CI_PHASES
YP_CI_STEP_NAME
YP_CI_ECHO
YP_CI_ECHO_BENCHMARK
YP_CI_ECHO_EXTERNAL_HONEYCOMB_API_KEY
YP_CI_ECHO_EXTERNAL_HONEYCOMB_DATASET
YP_CI_ECHO_EXTERNAL_HONEYCOMB_SERVICE_NAME
YP_CI_ECHO_EXTERNAL_HONEYCOMB_TRACE_ID
YP_CI_STATUS

# TODO should be renamed to not have a YP_CI_ prefix
YP_CI_BREW_INSTALL
EOF
}
