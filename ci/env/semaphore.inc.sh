#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_semaphore() {
    [[ "${SEMAPHORE:-}" = "true" ]] || return 0

    CI_NAME="Semaphore CI"
    CI_PLATFORM=semaphore

    git config --global user.email "${CI_PLATFORM}@semaphoreci.com"
    git config --global user.name "${CI_NAME}"

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    CI_JOB_ID=${SEMAPHORE_JOB_ID}
    CI_JOB_URL="${SEMAPHORE_ORGANIZATION_URL}/jobs/${CI_JOB_ID}"
    CI_REPO_SLUG=${SEMAPHORE_GIT_REPO_SLUG}
    CI_IS_PR=false
    if [[ -n "${SEMAPHORE_GIT_PR_SLUG:-}" ]]; then
        CI_IS_PR=true
    fi
    CI_PR_SLUG=${SEMAPHORE_GIT_PR_SLUG:-}
    CI_IS_CRON=${SEMAPHORE_WORKFLOW_TRIGGERED_BY_SCHEDULE}
    CI_TAG=${SEMAPHORE_GIT_TAG_NAME:-}
}
