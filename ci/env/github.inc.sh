#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_github() {
    [[ "${GITHUB_ACTIONS:-}" = "true" ]] || return 0

    export CI=true
    SF_CI_NAME="GitHub Actions"
    SF_CI_PLATFORM=github
    SF_CI_SERVER_HOST=${GITHUB_SERVER_URL:-github.com}
    SF_CI_SERVER_HOST=${SF_CI_SERVER_HOST#*://}
    SF_CI_REPO_SLUG=${GITHUB_REPOSITORY}
    SF_CI_ROOT=${GITHUB_WORKSPACE:-}

    SF_CI_IS_CRON=
    [[ -n "${GITHUB_EVENT_NAME:-}" ]] || SF_CI_IS_CRON=true
    SF_CI_IS_PR=
    [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]] || SF_CI_IS_PR=true

    SF_CI_JOB_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/github-get-job-id)
    SF_CI_PIPELINE_ID=${GITHUB_RUN_ID:-}
    # SF_CI_JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME"
    SF_CI_JOB_URL="${GITHUB_SERVER_URL:-}/${SF_CI_REPO_SLUG}/runs/${SF_CI_JOB_ID}?check_suite_focus=true"
    SF_CI_PIPELINE_URL="${GITHUB_SERVER_URL:-}/${SF_CI_REPO_SLUG}/actions/runs/${SF_CI_PIPELINE_ID}"

    SF_CI_PR_NUMBER=
    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        [[ -e "${GITHUB_EVENT_PATH:-}" ]] || \
            SF_CI_PR_NUMBER=$(jq -r .number ${GITHUB_EVENT_PATH})
        [[ -e "${GITHUB_EVENT_PATH:-}" ]] || \
            SF_CI_PR_URL=$(jq -r .pull_request.url ${GITHUB_EVENT_PATH})
        [[ -e "${GITHUB_EVENT_PATH:-}" ]] || \
            SF_CI_PR_REPO_SLUG=$(jq -r .pull_request.head.repo.full_name ${GITHUB_EVENT_PATH})
        [[ -e "${GITHUB_EVENT_PATH:-}" ]] || \
            SF_CI_PR_GIT_HASH=$(jq -r .pull_request.head.sha ${GITHUB_EVENT_PATH})
        [[ -e "${GITHUB_EVENT_PATH:-}" ]] || \
            SF_CI_PR_GIT_BRANCH=$(jq -r .pull_request.head.ref ${GITHUB_EVENT_PATH})
    }

    SF_CI_GIT_HASH=${GITHUB_SHA:-}
    SF_CI_GIT_BRANCH=
    GITHUB_REF=${GITHUB_REF:-}
    [[ ! "${GITHUB_REF:-}" =~ ^refs/heads/ ]] || SF_CI_GIT_BRANCH=${GITHUB_REF#refs/heads/}
    SF_CI_GIT_TAG=
    [[ ! "${GITHUB_REF:-}" =~ ^refs/tags/ ]] || SF_CI_GIT_TAG=${GITHUB_REF#refs/tags/}

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_github() {
    export GITHUB_EVENT_JSON="$(cat ${GITHUB_EVENT_PATH} | jq -c .)"
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^GITHUB[=_]" \
        -e "^RUNNER[=_]"
}

function sf_ci_known_env_github() {
    # see https://docs.github.com/en/actions/reference/environment-variables#default-environment-variables
    cat <<EOF
CI
GITHUB_WORKFLOW
GITHUB_RUN_ID
GITHUB_RUN_NUMBER
GITHUB_JOB
GITHUB_ACTION
GITHUB_ACTION_PATH
GITHUB_ACTIONS
GITHUB_ACTOR
GITHUB_REPOSITORY
GITHUB_EVENT_NAME
GITHUB_EVENT_PATH
GITHUB_WORKSPACE
GITHUB_SHA
GITHUB_REF
GITHUB_HEAD_REF
GITHUB_BASE_REF
GITHUB_SERVER_URL
GITHUB_API_URL
GITHUB_GRAPHQL_URL
RUNNER_OS
RUNNER_TEMP
RUNNER_TOOL_CACHE
EOF
    # undocumented but observed
    cat <<EOF
GITHUB_ACTION_REF
GITHUB_ACTION_REPOSITORY
GITHUB_ENV
GITHUB_JOB_NAME
GITHUB_PATH
GITHUB_REPOSITORY_OWNER
GITHUB_RETENTION_DAYS
GITHUB_TOKEN
RUNNER_PERFLOG
RUNNER_TRACKING_ID
RUNNER_USER
RUNNER_WORKSPACE
EOF
    # see sf_ci_printvars_github above
    cat <<EOF
GITHUB_EVENT_JSON
EOF
}
