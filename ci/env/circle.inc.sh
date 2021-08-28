#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_circle() {
    [[ "${CIRCLECI:-}" = "true" ]] || return 0

    [[ "${CIRCLE_REPOSITORY_URL:-}" =~ github.com ]]

    export CI=true
    CI_NAME=CircleCI
    CI_PLATFORM=circle
    CI_SERVER_HOST=circleci.com
    CI_REPO_SLUG=${CIRCLE_PROJECT_USERNAME:-}/${CIRCLE_PROJECT_REPONAME:-}
    CI_ROOT=${CIRCLE_WORKING_DIRECTORY:-}

    CI_IS_CRON=${CI_IS_CRON:-} # needs to come from .circleci/config.yml
    CI_IS_PR=
    [[ -z "${CIRCLE_PR_NUMBER:-}" ]] || CI_IS_PR=true # only on forked PRs
    [[ -z "${CIRCLE_PULL_REQUEST:-}" ]] || CI_IS_PR=true

    CI_JOB_ID=${CIRCLE_BUILD_NUM:-}
    CI_PIPELINE_ID=${CIRCLE_WORKFLOW_ID:-}
    CI_JOB_URL=${CIRCLE_BUILD_URL:-}
    # see https://discuss.circleci.com/t/add-a-workflow-url-like-the-previous-v1-job-api-job-url-to-the-get-pipeline-pipeline-id-workflow-api/35921 # editorconfig-checker-disable-line
    CI_PIPELINE_URL=https://app.${CI_SERVER_HOST}/pipelines/workflows/${CI_PIPELINE_ID}

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL=https://github.com/${CI_REPO_SLUG}/pull/${CIRCLE_PR_NUMBER:-}
        CI_PR_REPO_SLUG=${CIRCLE_PR_USERNAME:-}/${CIRCLE_PR_REPONAME:-}
        CI_PR_GIT_HASH= # TODO
        CI_PR_GIT_BRANCH=${CIRCLE_BRANCH:-}
    }

    CI_GIT_HASH=${CIRCLE_SHA1:-}
    CI_GIT_BRANCH=${CIRCLE_BRANCH:-}
    [[ "${CI_IS_PR}" != "true" ]] || CI_GIT_BRANCH=
    CI_GIT_TAG=${CIRCLE_TAG:-}

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    export USER=$(whoami)
}

function sf_ci_printvars_circle() {
    printenv | grep \
        -e "^CI[=_]" \
        -e "^CIRCLE[=_]" \
        -e "^CIRCLECI$"
}

function sf_ci_known_env_circle() {
    # see https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables
    cat <<EOF
CI
CIRCLECI
CIRCLE_BRANCH
CIRCLE_BUILD_NUM
CIRCLE_BUILD_URL
CIRCLE_JOB
CIRCLE_NODE_INDEX
CIRCLE_NODE_TOTAL
CIRCLE_PR_NUMBER
CIRCLE_PR_REPONAME
CIRCLE_PR_USERNAME
CIRCLE_PREVIOUS_BUILD_NUM
CIRCLE_PROJECT_REPONAME
CIRCLE_PROJECT_USERNAME
CIRCLE_PULL_REQUEST
CIRCLE_PULL_REQUESTS
CIRCLE_REPOSITORY_URL
CIRCLE_SHA1
CIRCLE_TAG
CIRCLE_USERNAME
CIRCLE_WORKFLOW_ID
CIRCLE_WORKING_DIRECTORY
CIRCLE_INTERNAL_TASK_DATA
CIRCLE_COMPARE_URL
CI_PULL_REQUEST
CI_PULL_REQUESTS
EOF
    # undocumented but observed
    cat <<EOF
CIRCLE_INTERNAL_CONFIG
CIRCLE_INTERNAL_SCRATCH
CIRCLE_SHELL_ENV
CIRCLE_STAGE
CIRCLE_WORKFLOW_JOB_ID
CIRCLE_WORKFLOW_UPSTREAM_JOB_IDS
CIRCLE_WORKFLOW_WORKSPACE_ID
EOF
}
