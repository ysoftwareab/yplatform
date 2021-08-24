#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_circle() {
    [[ "${CIRCLECI:-}" = "true" ]] || return 0

    CI_NAME=CircleCI
    CI_PLATFORM=circle

    git config --global user.email "${CI_PLATFORM}@circleci.com"
    git config --global user.name "${CI_NAME}"

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    CI_JOB_ID=${CIRCLE_WORKFLOW_JOB_ID}
    CI_JOB_URL=https://circleci.com/workflow-run/${CIRCLE_WORKFLOW_ID}
    CI_PR_SLUG=${CIRCLE_PR_USERNAME:-}/${CIRCLE_PR_REPONAME:-}
    CI_REPO_SLUG=${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}
    CI_IS_PR=
    if [[ -n "${CIRCLE_PR_NUMBER:-}" || -n "${CIRCLE_PULL_REQUEST:-}" ]]; then
        CI_IS_PR=true
    fi
    CI_IS_CRON=${CI_IS_CRON:-} # needs to come from .circleci/config.yml
    CI_TAG=${CIRCLE_TAG:-}
    export USER=$(whoami)
}

function sf_ci_printvars_circle() {
    printenv | grep "^CI[=_]"
    printenv | grep "^CIRCLE[=_]"
}
