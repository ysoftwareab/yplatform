#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_github() {
    [[ "${GITHUB_ACTIONS:-}" = "true" ]] || return 0

    CI_NAME="Github Actions"
    CI_PLATFORM=github

    git config --global user.email "${CI_PLATFORM}@github.com"
    git config --global user.name "${CI_NAME}"

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    # travis -> github actions
    # builds -> workflow runs
    # jobs   -> job runs
    CI_JOB_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/github-get-job-id)
    # CI_JOB_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME"
    CI_JOB_URL="https://github.com/${GITHUB_REPOSITORY}/runs/${CI_JOB_ID}?check_suite_focus=true"
    CI_REPO_SLUG=${GITHUB_REPOSITORY}
    CI_IS_PR=
    CI_PR_SLUG=
    if [[ "${GITHUB_EVENT_NAME}" = "pull_request" ]]; then
        CI_IS_PR=true
        CI_PR_SLUG=$(jq -r .github.event.pull_request.url ${GITHUB_EVENT_PATH})
    fi
    CI_IS_CRON=
    if [[ -z "${GITHUB_EVENT_NAME}" ]]; then
        CI_IS_CRON=true
    fi
    CI_TAG=
    if [[ "${GITHUB_REF:-}" =~ ^refs/tags/ ]]; then
        CI_TAG=${GITHUB_REF#refs\/tags\/}
    fi
    export CI=true
}

function sf_ci_printvars_github() {
    printenv | grep "^CI[=_]"
    printenv | grep "^GITHUB[=_]"
}
