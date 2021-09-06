#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_zz() {
    [[ "${CI:-}" = "true" ]] || return 0
    [[ -z "${SF_CI_PLATFORM:-}" ]] || return 0

    export CI=true
    SF_CI_NAME="$(whoami)@$(hostname)"
    SF_CI_PLATFORM=zz
    SF_CI_SERVER_HOST=$(hostname)
    SF_CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep -oP "(?<=.com.).+" | grep -oP ".+(?= \(fetch\))" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
    SF_CI_ROOT=${GIT_ROOT:-}

    SF_CI_IS_CRON=
    SF_CI_IS_PR=

    SF_CI_JOB_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/random-hex)
    SF_CI_PIPELINE_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/random-hex)
    SF_CI_JOB_URL=https://example.com/${SF_CI_NAME}/${SF_CI_REPO_SLUG}/job/${SF_CI_JOB_ID}
    SF_CI_PIPELINE_URL=https://example.com/${SF_CI_NAME}/${SF_CI_REPO_SLUG}/pipeline/${SF_CI_PIPELINE_ID}

    SF_CI_PR_NUMBER=
    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=

    SF_CI_GIT_HASH=${GIT_HASH:-}
    SF_CI_GIT_BRANCH=${GIT_BRANCH:-}
    SF_CI_GIT_TAG=${GIT_TAG:-}

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_zz() {
    true
}

function sf_ci_known_env_zz() {
    true
}
