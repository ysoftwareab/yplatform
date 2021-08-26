#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://docs.semaphoreci.com/ci-cd-environment/environment-variables/

function sf_ci_env_semaphore() {
    [[ "${SEMAPHORE:-}" = "true" ]] || return 0

    export CI=true
    CI_NAME=Semaphore
    CI_PLATFORM=semaphore
    CI_SERVER_HOST=${SEMAPHORE_ORGANIZATION_URL:-semaphoreci.com}
    CI_SERVER_HOST=${CI_SERVER_HOST#*://}
    CI_REPO_SLUG=${SEMAPHORE_GIT_REPO_SLUG:-}
    CI_ROOT=${SEMAPHORE_GIT_DIR:-}

    CI_IS_CRON=${SEMAPHORE_WORKFLOW_TRIGGERED_BY_SCHEDULE:-}
    CI_IS_PR=
    [[ -z "${SEMAPHORE_GIT_PR_SLUG:-}" ]] || CI_IS_PR=true

    CI_JOB_ID=${SEMAPHORE_JOB_ID:-}
    CI_PIPELINE_ID=${SEMAPHORE_WORKFLOW_ID:-}
    CI_JOB_URL="${SEMAPHORE_ORGANIZATION_URL:-}/jobs/${CI_JOB_ID}"
    CI_PIPELINE_URL="${SEMAPHORE_ORGANIZATION_URL:-}/workflows/${CI_PIPELINE_ID}"

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL=https://github.com/${CI_REPO_SLUG}/pull/${SEMAPHORE_GIT_PR_NUMBER:-}
        CI_PR_REPO_SLUG=${SEMAPHORE_GIT_PR_SLUG:-}
        CI_PR_GIT_HASH=${SEMAPHORE_GIT_PR_SHA:-}
        CI_PR_GIT_BRANCH=${SEMAPHORE_GIT_PR_BRANCH:-}
    }

    CI_GIT_HASH=${SEMAPHORE_GIT_SHA:-}
    CI_GIT_BRANCH=${SEMAPHORE_GIT_BRANCH:-}
    CI_GIT_TAG=${SEMAPHORE_GIT_TAG_NAME:-}

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
}

function sf_ci_printvars_semaphore() {
    printenv | grep "^CI[=_]"
    printenv | grep "^SEMAPHORE[=_]"
}
