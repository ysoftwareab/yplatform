#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_sf() {
    true
}

function sf_ci_printvars_sf() {
    printenv_all | sort -u | grep \
        -e "^CI=" \
        -e "^SF_CI_"
}

function sf_ci_known_env_sf() {
    # keep in sync with ci/README.md
    cat <<EOF | sort -u | grep -v -e "^$" -e "^#"
# core
CI
SF_CI_NAME
SF_CI_PLATFORM
SF_CI_SERVER_HOST
SF_CI_REPO_SLUG
SF_CI_ROOT

# is
SF_CI_IS_CRON
SF_CI_IS_PR

# job/pipeline
SF_CI_JOB_ID
SF_CI_PIPELINE_ID
SF_CI_JOB_URL
SF_CI_PIPELINE_URL

# pr
SF_CI_PR_URL
SF_CI_PR_REPO_SLUG
SF_CI_PR_GIT_HASH
SF_CI_PR_GIT_BRANCH

# git
SF_CI_GIT_HASH
SF_CI_GIT_BRANCH
SF_CI_GIT_TAG

# misc
SF_CI_BREW_INSTALL
SF_CI_DEBUG_MODE
SF_CI_PHASES
SF_CI_STEP_NAME
SF_CI_ECHO
SF_CI_ECHO_BENCHMARK
SF_CI_STATUS
EOF
}
