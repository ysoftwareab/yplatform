#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://docs.github.com/en/actions/reference/environment-variables#default-environment-variables

function sf_ci_env_github() {
    [[ "${GITHUB_ACTIONS:-}" = "true" ]] || return 0

    export CI=true
    CI_NAME="Github Actions"
    CI_PLATFORM=github
    CI_SERVER_HOST=${GITHUB_SERVER_URL:-github.com}
    CI_SERVER_HOST=${CI_SERVER_HOST#*://}
    CI_REPO_SLUG=${GITHUB_REPOSITORY}
    CI_ROOT=${GITHUB_WORKSPACE:-}

    CI_IS_CRON=
    [[ -n "${GITHUB_EVENT_NAME:-}" ]] || CI_IS_CRON=true
    CI_IS_PR=
    [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]] || CI_IS_PR=true

    CI_JOB_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/github-get-job-id)
    CI_PIPELINE_ID=${GITHUB_RUN_ID:-}
    # CI_JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME"
    CI_JOB_URL="${GITHUB_SERVER_URL:-}/${CI_REPO_SLUG}/runs/${CI_JOB_ID}?check_suite_focus=true"
    CI_PIPELINE_URL="${GITHUB_SERVER_URL:-}/${CI_REPO_SLUG}/actions/runs/${CI_PIPELINE_ID}"

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL=$(jq -r .github.event.pull_request.url ${GITHUB_EVENT_PATH})
        CI_PR_REPO_SLUG=$(jq -r .github.event.pull_request.head.repo.full_name ${GITHUB_EVENT_PATH})
        CI_PR_GIT_HASH=$(jq -r .github.event.pull_request.head.sha ${GITHUB_EVENT_PATH})
        CI_PR_GIT_BRANCH=$(jq -r .github.event.pull_request.head.ref ${GITHUB_EVENT_PATH})
    }

    CI_GIT_HASH=${GITHUB_SHA:-}
    CI_GIT_BRANCH=
    [[ ! "${GITHUB_REF:-}" =~ ^refs/heads/ ]] || CI_GIT_TAG=${GITHUB_REF#refs/heads/}
    CI_GIT_TAG=
    [[ ! "${GITHUB_REF:-}" =~ ^refs/tags/ ]] || CI_GIT_TAG=${GITHUB_REF#refs/tags/}

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
}

function sf_ci_printvars_github() {
    printenv | grep "^CI[=_]"
    printenv | grep "^GITHUB[=_]"
}
