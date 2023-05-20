#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_circle() {
    [[ "${CIRCLECI:-}" = "true" ]] || return 0

    [[ "${CIRCLE_REPOSITORY_URL:-}" =~ github.com ]]

    export CI=true
    YP_CI_NAME=CircleCI
    YP_CI_PLATFORM=circle
    YP_CI_SERVER_HOST=circleci.com
    YP_CI_REPO_SLUG=${CIRCLE_PROJECT_USERNAME:-}/${CIRCLE_PROJECT_REPONAME:-}
    YP_CI_ROOT=${CIRCLE_WORKING_DIRECTORY:-}

    YP_CI_IS_CRON=${YP_CI_IS_CRON:-} # needs to come from .circleci/config.yml
    YP_CI_IS_PR=
    [[ -z "${CIRCLE_PR_NUMBER:-}" ]] || YP_CI_IS_PR=true # only on forked PRs
    [[ -z "${CIRCLE_PULL_REQUEST:-}" ]] || YP_CI_IS_PR=true

    YP_CI_JOB_ID=${CIRCLE_BUILD_NUM:-}
    YP_CI_PIPELINE_ID=${CIRCLE_WORKFLOW_ID:-}
    YP_CI_JOB_URL=${CIRCLE_BUILD_URL:-}
    # see https://discuss.circleci.com/t/add-a-workflow-url-like-the-previous-v1-job-api-job-url-to-the-get-pipeline-pipeline-id-workflow-api/35921 # editorconfig-checker-disable-line
    YP_CI_PIPELINE_URL=https://app.${YP_CI_SERVER_HOST}/pipelines/workflows/${YP_CI_PIPELINE_ID}

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        YP_CI_PR_NUMBER=${CIRCLE_PR_NUMBER:-}
        YP_CI_PR_URL=https://github.com/${YP_CI_REPO_SLUG}/pull/${YP_CI_PR_NUMBER}
        YP_CI_PR_REPO_SLUG=${CIRCLE_PR_USERNAME:-}/${CIRCLE_PR_REPONAME:-}
        YP_CI_PR_GIT_HASH= # TODO
        YP_CI_PR_GIT_BRANCH=${CIRCLE_BRANCH:-}
    }

    YP_CI_GIT_HASH=${CIRCLE_SHA1:-}
    YP_CI_GIT_BRANCH=${CIRCLE_BRANCH:-}
    [[ "${YP_CI_IS_PR}" != "true" ]] || YP_CI_GIT_BRANCH=
    YP_CI_GIT_TAG=${CIRCLE_TAG:-}

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
    export USER=$(whoami)
}

function yp_ci_printvars_circle() {
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^CIRCLE[=_]" \
        -e "^CIRCLECI$"
}

function yp_ci_known_env_circle() {
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
CIRCLE_OIDC_TOKEN
CIRCLE_OIDC_TOKEN_V2
CIRCLE_PLUGIN_TEST
CIRCLE_SHELL_ENV
CIRCLE_STAGE
CIRCLE_WORKFLOW_JOB_ID
CIRCLE_WORKFLOW_UPSTREAM_JOB_IDS
CIRCLE_WORKFLOW_WORKSPACE_ID
EOF
}
