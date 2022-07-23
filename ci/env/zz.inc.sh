#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_zz() {
    [[ "${CI:-}" = "true" ]] || return 0
    [[ -z "${YP_CI_PLATFORM:-}" ]] || return 0

    export CI=true
    YP_CI_NAME="$(whoami)@$(hostname)"
    YP_CI_PLATFORM=zz
    YP_CI_SERVER_HOST=$(hostname)
    # BSD grep doesn't support -p (--perl-regexp)
    # YP_CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep -oP "(?<=.com.).+" | grep -oP ".+(?= \(fetch\))" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
    YP_CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep ".com." | grep " (fetch)" | sed "s/.*.com.//" | sed "s/ (fetch)//" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
    YP_CI_ROOT=${GIT_ROOT:-}

    YP_CI_IS_CRON=
    YP_CI_IS_PR=

    YP_CI_JOB_ID=$(${YP_DIR}/bin/random-hex)
    YP_CI_PIPELINE_ID=$(${YP_DIR}/bin/random-hex)
    YP_CI_JOB_URL=https://example.com/${YP_CI_NAME}/${YP_CI_REPO_SLUG}/job/${YP_CI_JOB_ID}
    YP_CI_PIPELINE_URL=https://example.com/${YP_CI_NAME}/${YP_CI_REPO_SLUG}/pipeline/${YP_CI_PIPELINE_ID}

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=

    YP_CI_GIT_HASH=${GIT_HASH:-}
    YP_CI_GIT_BRANCH=${GIT_BRANCH:-}
    YP_CI_GIT_TAG=${GIT_TAG:-}

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
}

function yp_ci_printvars_zz() {
    true
}

function yp_ci_known_env_zz() {
    true
}
