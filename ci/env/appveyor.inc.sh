#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://www.appveyor.com/docs/environment-variables/

function sf_ci_env_appveyor() {
    [[ "${APPVEYOR:-}" = "true" ]] || return 0

    [[ "${APPVEYOR_REPO_PROVIDER:-}" = "github" ]]

    export CI=true
    CI_NAME=Appveyor
    CI_PLATFORM=appveyor
    CI_SERVER_HOST=${APPVEYOR_URL:-ci.appveyor.com}
    CI_SERVER_HOST=${CI_SERVER_HOST#*://}
    CI_REPO_SLUG=${APPVEYOR_REPO_NAME:-}
    CI_ROOT=${APPVEYOR_BUILD_FOLDER}

    CI_IS_CRON=${APPVEYOR_SCHEDULED_BUILD:-}
    CI_IS_PR=
    [[ -z "${APPVEYOR_PULL_REQUEST_NUMBER:-}" ]] || CI_IS_PR=true

    CI_JOB_ID=${APPVEYOR_JOB_ID:-}
    CI_PIPELINE_ID=${APPVEYOR_BUILD_NUMBER:-}
    # CI_JOB_URL=${CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/builds/${CI_JOB_ID}
    CI_JOB_URL=${CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/build/job/${CI_JOB_ID}
    CI_PIPELINE_URL=${CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/build/${CI_PIPELINE_ID} # editorconfig-checker-disable-line

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_REPO_URL=https://github.com/${CI_REPO_SLUG}/pull/${APPVEYOR_PULL_REQUEST_NUMBER:-}
        CI_PR_REPO_SLUG=${APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME:-}
        CI_PR_GIT_HASH=${APPVEYOR_PULL_REQUEST_HEAD_COMMIT:-}
        CI_PR_GIT_BRANCH=${APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH:-}
    }

    CI_GIT_HASH=${APPVEYOR_REPO_COMMIT:-}
    CI_GIT_BRANCH=${APPVEYOR_REPO_BRANCH:-}
    CI_GIT_TAG=${APPVEYOR_REPO_TAG_NAME:-}

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
}

function sf_ci_printvars_appveyor() {
    printenv | grep "^CI[=_]"
    printenv | grep "^APPVEYOR[=_]"
}
