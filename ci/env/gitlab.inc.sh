#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_gitlab() {
    [[ "${GITLAB_CI:-}" = "true" ]] || return 0

    CI_NAME=Gitlab
    CI_PLATFORM=gitlab

    git config --global user.email "${CI_PLATFORM}@gitlab.com"
    git config --global user.name "${CI_NAME}"

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    # CI_JOB_ID=
    # CI_JOB_URL=
    CI_REPO_SLUG=${CI_PROJECT_PATH}
    CI_IS_PR=$([[ -n "${CI_MERGE_REQUEST_ID:-}" ]] && echo true || echo false)
    CI_IS_CRON=$([[ "${CI_PIPELINE_SOURCE}" = "schedule" ]] && echo true || echo false)
    # CI_TAG=
}
