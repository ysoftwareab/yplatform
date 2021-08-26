#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://docs.gitlab.com/ee/ci/variables/predefined_variables.html

function sf_ci_env_gitlab() {
    [[ "${GITLAB_CI:-}" = "true" ]] || return 0

    # TODO handle external_pull_request_event
    [[ "${CI_PIPELINE_SOURCE:-}" != "external_pull_request_event" ]]

    export CI=true
    CI_NAME="Gitlab CI/CD"
    CI_PLATFORM=gitlab
    CI_SERVER_HOST=${CI_SERVER_HOST:-gitlab.com}
    CI_REPO_SLUG=${CI_PROJECT_PATH:-}
    CI_ROOT=${CI_PROJECT_DIR:-}

    CI_IS_CRON=
    [[ "${CI_PIPELINE_SOURCE:-}" != "schedule" ]] || CI_IS_CRON=true
    CI_IS_PR=
    [[ -z "${CI_MERGE_REQUEST_ID:-}" ]] || CI_IS_PR=true

    # 1 pipeline -> n jobs
    CI_JOB_ID=${CI_JOB_ID:-}
    CI_PIPELINE_ID=${CI_PIPELINE_ID:-}
    CI_JOB_URL=${CI_JOB_URL:-}
    CI_PIPELINE_URL=${CI_PIPELINE_URL:-${CI_PROJECT_URL}/pipelines/${CI_PIPELINE_ID}}

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL=${CI_PROJECT_URL}/-/merge_requests/${CI_MERGE_REQUEST_ID:-}
        CI_PR_REPO_SLUG=${CI_MERGE_REQUEST_SOURCE_PROJECT_PATH:-}
        CI_PR_GIT_HASH=${CI_MERGE_REQUEST_SOURCE_BRANCH_SHA:-}
        CI_PR_GIT_BRANCH=${CI_MERGE_REQUEST_SOURCE_BRANCH_NAME:-}
    }

    CI_GIT_HASH=${CI_COMMIT_SHA:-}
    CI_GIT_BRANCH=${CI_COMMIT_REF_NAME:-}
    [[ "${CI_IS_PR}" != "true" ]] || CI_GIT_BRANCH=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME:-}
    CI_GIT_TAG=${CI_COMMIT_TAG:-}

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
}

function sf_ci_printvars_gitlab() {
    printenv | grep "^CI[=_]"
    printenv | grep "^GITLAB[=_]"
    printenv | grep "^TRIGGER_PAYLOAD="
}
