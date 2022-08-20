#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_gitlab() {
    [[ "${GITLAB_CI:-}" = "true" ]] || return 0

    # TODO handle external_pull_request_event
    [[ "${CI_PIPELINE_SOURCE:-}" != "external_pull_request_event" ]]

    export CI=true
    YP_CI_NAME="GitLab CI/CD"
    YP_CI_PLATFORM=gitlab
    YP_CI_SERVER_HOST=${CI_SERVER_HOST:-gitlab.com}
    YP_CI_REPO_SLUG=${CI_PROJECT_PATH:-}
    YP_CI_ROOT=${CI_PROJECT_DIR:-}

    YP_CI_IS_CRON=
    [[ "${CI_PIPELINE_SOURCE:-}" != "schedule" ]] || YP_CI_IS_CRON=true
    YP_CI_IS_PR=
    [[ -z "${CI_MERGE_REQUEST_ID:-}" ]] || YP_CI_IS_PR=true

    # 1 pipeline -> n jobs
    YP_CI_JOB_ID=${CI_JOB_ID:-}
    YP_CI_PIPELINE_ID=${CI_PIPELINE_ID:-}
    YP_CI_JOB_URL=${CI_JOB_URL:-}
    YP_CI_PIPELINE_URL=${CI_PIPELINE_URL:-${CI_PROJECT_URL:-}/-/pipelines/${YP_CI_PIPELINE_ID}}

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        YP_CI_PR_NUMBER=${CI_MERGE_REQUEST_ID:-}
        YP_CI_PR_URL=${CI_PROJECT_URL:-}/-/merge_requests/${YP_CI_PR_NUMBER}
        YP_CI_PR_REPO_SLUG=${CI_MERGE_REQUEST_SOURCE_PROJECT_PATH:-}
        YP_CI_PR_GIT_HASH=${CI_MERGE_REQUEST_SOURCE_BRANCH_SHA:-}
        YP_CI_PR_GIT_BRANCH=${CI_MERGE_REQUEST_SOURCE_BRANCH_NAME:-}
    }

    YP_CI_GIT_HASH=${CI_COMMIT_SHA:-}
    YP_CI_GIT_BRANCH=${CI_COMMIT_REF_NAME:-}
    [[ "${YP_CI_IS_PR}" != "true" ]] || YP_CI_GIT_BRANCH=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME:-}
    YP_CI_GIT_TAG=${CI_COMMIT_TAG:-}

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
}

function yp_ci_printvars_gitlab() {
    printenv_all | sort -u | grep \
        -e "^CHAT[=_]" \
        -e "^CI[=_]" \
        -e "^GITLAB[=_]" \
        -e "^TRIGGER_PAYLOAD="
}

function yp_ci_known_env_gitlab() {
    # see https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
    cat <<EOF
CHAT_CHANNEL
CHAT_INPUT
CI
CI_API_V4_URL
CI_BUILDS_DIR
CI_COMMIT_AUTHOR
CI_COMMIT_BEFORE_SHA
CI_COMMIT_BRANCH
CI_COMMIT_DESCRIPTION
CI_COMMIT_MESSAGE
CI_COMMIT_REF_NAME
CI_COMMIT_REF_PROTECTED
CI_COMMIT_REF_SLUG
CI_COMMIT_SHA
CI_COMMIT_SHORT_SHA
CI_COMMIT_TAG
CI_COMMIT_TIMESTAMP
CI_COMMIT_TITLE
CI_CONCURRENT_ID
CI_CONCURRENT_PROJECT_ID
CI_CONFIG_PATH
CI_DEBUG_TRACE
CI_DEFAULT_BRANCH
CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX
CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX
CI_DEPENDENCY_PROXY_PASSWORD
CI_DEPENDENCY_PROXY_SERVER
CI_DEPENDENCY_PROXY_USER
CI_DEPLOY_FREEZE
CI_DEPLOY_PASSWORD
CI_DEPLOY_USER
CI_DISPOSABLE_ENVIRONMENT
CI_ENVIRONMENT_NAME
CI_ENVIRONMENT_SLUG
CI_ENVIRONMENT_URL
CI_ENVIRONMENT_ACTION
CI_ENVIRONMENT_TIER
CI_HAS_OPEN_REQUIREMENTS
CI_JOB_ID
CI_JOB_IMAGE
CI_JOB_JWT
CI_JOB_JWT_V1
CI_JOB_JWT_V2
CI_JOB_MANUAL
CI_JOB_NAME
CI_JOB_STAGE
CI_JOB_STATUS
CI_JOB_TOKEN
CI_JOB_URL
CI_JOB_STARTED_AT
CI_KUBERNETES_ACTIVE
CI_NODE_INDEX
CI_NODE_TOTAL
CI_OPEN_MERGE_REQUESTS
CI_PAGES_DOMAIN
CI_PAGES_URL
CI_PIPELINE_ID
CI_PIPELINE_IID
CI_PIPELINE_SOURCE
CI_PIPELINE_TRIGGERED
CI_PIPELINE_URL
CI_PIPELINE_CREATED_AT
CI_PROJECT_CONFIG_PATH
CI_PROJECT_DESCRIPTION
CI_PROJECT_DIR
CI_PROJECT_ID
CI_PROJECT_NAME
CI_PROJECT_NAMESPACE
CI_PROJECT_PATH_SLUG
CI_PROJECT_PATH
CI_PROJECT_REPOSITORY_LANGUAGES
CI_PROJECT_ROOT_NAMESPACE
CI_PROJECT_TITLE
CI_PROJECT_URL
CI_PROJECT_VISIBILITY
CI_PROJECT_CLASSIFICATION_LABEL
CI_REGISTRY_IMAGE
CI_REGISTRY_PASSWORD
CI_REGISTRY_USER
CI_REGISTRY
CI_REPOSITORY_URL
CI_RUNNER_DESCRIPTION
CI_RUNNER_EXECUTABLE_ARCH
CI_RUNNER_ID
CI_RUNNER_REVISION
CI_RUNNER_SHORT_TOKEN
CI_RUNNER_TAGS
CI_RUNNER_VERSION
CI_SERVER_HOST
CI_SERVER_NAME
CI_SERVER_PORT
CI_SERVER_PROTOCOL
CI_SERVER_REVISION
CI_SERVER_URL
CI_SERVER_VERSION_MAJOR
CI_SERVER_VERSION_MINOR
CI_SERVER_VERSION_PATCH
CI_SERVER_VERSION
CI_SERVER
CI_SHARED_ENVIRONMENT
GITLAB_CI
GITLAB_FEATURES
GITLAB_USER_EMAIL
GITLAB_USER_ID
GITLAB_USER_LOGIN
GITLAB_USER_NAME
TRIGGER_PAYLOAD
EOF
    # undocumented but observed
    cat <<EOF
CI_BUILD_BEFORE_SHA
CI_BUILD_ID
CI_BUILD_NAME
CI_BUILD_REF
CI_BUILD_REF_NAME
CI_BUILD_REF_SLUG
CI_BUILD_STAGE
CI_BUILD_TOKEN
CI_SERVER_TLS_CA_FILE
CI_TEMPLATE_REGISTRY_HOST
EOF
}
