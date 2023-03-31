#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_github() {
    [[ "${GITHUB_ACTIONS:-}" = "true" ]] || return 0

    export CI=true
    YP_CI_NAME="GitHub Actions"
    YP_CI_PLATFORM=github
    YP_CI_SERVER_HOST=${GITHUB_SERVER_URL:-github.com}
    YP_CI_SERVER_HOST=${YP_CI_SERVER_HOST#*://}
    YP_CI_REPO_SLUG=${GITHUB_REPOSITORY}
    YP_CI_ROOT=${GITHUB_WORKSPACE:-}

    YP_CI_IS_CRON=
    [[ -n "${GITHUB_EVENT_NAME:-}" ]] || YP_CI_IS_CRON=true
    YP_CI_IS_PR=
    [[ "${GITHUB_EVENT_NAME:-}" != "pull_request" ]] || YP_CI_IS_PR=true

    YP_CI_JOB_ID=$(${YP_DIR}/bin/github-get-job-id)
    YP_CI_PIPELINE_ID=${GITHUB_RUN_ID:-}
    # YP_CI_JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME"
    YP_CI_JOB_URL="${GITHUB_SERVER_URL:-}/${YP_CI_REPO_SLUG}/runs/${YP_CI_JOB_ID}?check_suite_focus=true"
    YP_CI_PIPELINE_URL="${GITHUB_SERVER_URL:-}/${YP_CI_REPO_SLUG}/actions/runs/${YP_CI_PIPELINE_ID}"

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        [[ ! -f "${GITHUB_EVENT_PATH:-}" ]] || \
            YP_CI_PR_NUMBER=$(jq -r .number ${GITHUB_EVENT_PATH})
        [[ ! -f "${GITHUB_EVENT_PATH:-}" ]] || \
            YP_CI_PR_URL=$(jq -r .pull_request.url ${GITHUB_EVENT_PATH})
        [[ ! -f "${GITHUB_EVENT_PATH:-}" ]] || \
            YP_CI_PR_REPO_SLUG=$(jq -r .pull_request.head.repo.full_name ${GITHUB_EVENT_PATH})
        [[ ! -f "${GITHUB_EVENT_PATH:-}" ]] || \
            YP_CI_PR_GIT_HASH=$(jq -r .pull_request.head.sha ${GITHUB_EVENT_PATH})
        [[ ! -f "${GITHUB_EVENT_PATH:-}" ]] || \
            YP_CI_PR_GIT_BRANCH=$(jq -r .pull_request.head.ref ${GITHUB_EVENT_PATH})
    }

    YP_CI_GIT_HASH=${GITHUB_SHA:-}
    YP_CI_GIT_BRANCH=
    GITHUB_REF=${GITHUB_REF:-}
    [[ ! "${GITHUB_REF:-}" =~ ^refs/heads/ ]] || YP_CI_GIT_BRANCH=${GITHUB_REF#refs/heads/}
    [[ "${YP_CI_IS_PR}" != "true" ]] || YP_CI_GIT_BRANCH=${GITHUB_BASE_REF:-}
    YP_CI_GIT_TAG=
    [[ ! "${GITHUB_REF:-}" =~ ^refs/tags/ ]] || YP_CI_GIT_TAG=${GITHUB_REF#refs/tags/}

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
}

function yp_ci_printvars_github() {
    export GITHUB_EVENT_JSON="$(cat ${GITHUB_EVENT_PATH} | jq -c .)"
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^ACTIONS_RUNNER_[=_]" \
        -e "^GITHUB[=_]" \
        -e "^RUNNER[=_]"
}

function yp_ci_known_env_github() {
    # see https://docs.github.com/en/actions/reference/environment-variables#default-environment-variables
    # see https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging
    cat <<EOF
ACTIONS_RUNNER_DEBUG
ACTIONS_STEP_DEBUG
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
RUNNER_NAME
RUNNER_OS
RUNNER_TEMP
RUNNER_TOOL_CACHE
EOF
    # undocumented but observed
    cat <<EOF
GITHUB_ACTION_REF
GITHUB_ACTION_REPOSITORY
GITHUB_ACTOR_ID
GITHUB_ENV
GITHUB_JOB_NAME
GITHUB_OUTPUT
GITHUB_PATH
GITHUB_REF_NAME
GITHUB_REF_PROTECTED
GITHUB_REF_TYPE
GITHUB_REPOSITORY_ID
GITHUB_REPOSITORY_OWNER
GITHUB_REPOSITORY_OWNER_ID
GITHUB_RETENTION_DAYS
GITHUB_RUN_ATTEMPT
GITHUB_STATE
GITHUB_STEP_SUMMARY
GITHUB_TOKEN
GITHUB_TRIGGERING_ACTOR
GITHUB_WORKFLOW_REF
GITHUB_WORKFLOW_SHA
RUNNER_ARCH
RUNNER_PERFLOG
RUNNER_TRACKING_ID
RUNNER_USER
RUNNER_WORKSPACE
EOF
    # see yp_ci_printvars_github above
    cat <<EOF
GITHUB_EVENT_JSON
EOF
    # see bin/github-get-job-id
    cat <<EOF
GITHUB_JOB_ID
EOF
    # see mk/git.inc.mk
    # see sh/git.inc.sh
    cat <<EOF
GITHUB_SERVER_URL_DOMAIN
EOF
}
