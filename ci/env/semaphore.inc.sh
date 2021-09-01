#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_semaphore() {
    [[ "${SEMAPHORE:-}" = "true" ]] || return 0

    export CI=true
    SF_CI_NAME=Semaphore
    SF_CI_PLATFORM=semaphore
    SF_CI_SERVER_HOST=${SEMAPHORE_ORGANIZATION_URL:-semaphoreci.com}
    SF_CI_SERVER_HOST=${SF_CI_SERVER_HOST#*://}
    SF_CI_REPO_SLUG=${SEMAPHORE_GIT_REPO_SLUG:-}
    SF_CI_ROOT=${SEMAPHORE_GIT_DIR:-}

    SF_CI_IS_CRON=${SEMAPHORE_WORKFLOW_TRIGGERED_BY_SCHEDULE:-}
    SF_CI_IS_PR=
    [[ -z "${SEMAPHORE_GIT_PR_SLUG:-}" ]] || SF_CI_IS_PR=true

    SF_CI_JOB_ID=${SEMAPHORE_JOB_ID:-}
    SF_CI_PIPELINE_ID=${SEMAPHORE_WORKFLOW_ID:-}
    SF_CI_JOB_URL="${SEMAPHORE_ORGANIZATION_URL:-}/jobs/${SF_CI_JOB_ID}"
    SF_CI_PIPELINE_URL="${SEMAPHORE_ORGANIZATION_URL:-}/workflows/${SF_CI_PIPELINE_ID}"

    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        SF_CI_PR_URL=https://github.com/${SF_CI_REPO_SLUG}/pull/${SEMAPHORE_GIT_PR_NUMBER:-}
        SF_CI_PR_REPO_SLUG=${SEMAPHORE_GIT_PR_SLUG:-}
        SF_CI_PR_GIT_HASH=${SEMAPHORE_GIT_PR_SHA:-}
        SF_CI_PR_GIT_BRANCH=${SEMAPHORE_GIT_PR_BRANCH:-}
    }

    SF_CI_GIT_HASH=${SEMAPHORE_GIT_SHA:-}
    SF_CI_GIT_BRANCH=${SEMAPHORE_GIT_BRANCH:-}
    SF_CI_GIT_TAG=${SEMAPHORE_GIT_TAG_NAME:-}

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_semaphore() {
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^SEMAPHORE[=_]"
}

function sf_ci_known_env_semaphore() {
    # see https://docs.semaphoreci.com/ci-cd-environment/environment-variables/
    cat <<EOF
CI
SEMAPHORE
SEMAPHORE_PROJECT_NAME
SEMAPHORE_PROJECT_ID
SEMAPHORE_ORGANIZATION_URL
SEMAPHORE_JOB_NAME
SEMAPHORE_JOB_ID
SEMAPHORE_JOB_RESULT
SEMAPHORE_WORKFLOW_ID
SEMAPHORE_WORKFLOW_NUMBER
SEMAPHORE_WORKFLOW_RERUN
SEMAPHORE_WORKFLOW_TRIGGERED_BY_HOOK
SEMAPHORE_WORKFLOW_TRIGGERED_BY_SCHEDULE
SEMAPHORE_WORKFLOW_TRIGGERED_BY_API
SEMAPHORE_PIPELINE_ID
SEMAPHORE_PIPELINE_PROMOTION
SEMAPHORE_PIPELINE_PROMOTED_BY
SEMAPHORE_PIPELINE_RERUN
SEMAPHORE_AGENT_MACHINE_TYPE
SEMAPHORE_AGENT_MACHINE_OS_IMAGE
SEMAPHORE_AGENT_MACHINE_ENVIRONMENT_TYPE
SEMAPHORE_GIT_SHA
SEMAPHORE_GIT_URL
SEMAPHORE_GIT_BRANCH
SEMAPHORE_GIT_DIR
SEMAPHORE_GIT_REPO_SLUG
SEMAPHORE_GIT_REF_TYPE
SEMAPHORE_GIT_REF
SEMAPHORE_GIT_COMMIT_RANGE
SEMAPHORE_GIT_TAG_NAME
SEMAPHORE_GIT_PR_BRANCH
SEMAPHORE_GIT_PR_SLUG
SEMAPHORE_GIT_PR_SHA
SEMAPHORE_GIT_PR_NUMBER
SEMAPHORE_GIT_PR_NAME
SEMAPHORE_CACHE_USERNAME
SEMAPHORE_CACHE_URL
SEMAPHORE_CACHE_PRIVATE_KEY_PATH
SEMAPHORE_REGISTRY_USERNAME
SEMAPHORE_REGISTRY_PASSWORD
SEMAPHORE_REGISTRY_URL
EOF
    # undocumented but observed
    cat <<EOF
SEMAPHORE_ARTIFACT_TOKEN
SEMAPHORE_ERLANG_VERSION
SEMAPHORE_PIPELINE_0_ARTEFACT_ID
SEMAPHORE_PIPELINE_ARTEFACT_ID
SEMAPHORE_SCALA_VERSION
SEMAPHORE_WORKFLOW_HOOK_SOURCE
EOF
}