#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_travis() {
    [[ "${TRAVIS:-}" = "true" ]] || return 0

    CI_NAME="Travis CI"
    CI_PLATFORM=travis

    git config --global user.email "${CI_PLATFORM}@travis-ci.com"
    git config --global user.name "${CI_NAME}"

    CI_DEBUG_MODE=${TRAVIS_DEBUG_MODE:-}
    CI_JOB_ID=${TRAVIS_JOB_ID}
    CI_JOB_URL=${TRAVIS_JOB_WEB_URL}
    CI_PR_SLUG=${TRAVIS_PULL_REQUEST_SLUG:-}
    CI_REPO_SLUG=${TRAVIS_REPO_SLUG}
    CI_IS_PR=false
    if [[ "${TRAVIS_EVENT_TYPE}" = "pull_request" ]]; then
        CI_IS_PR=true
    fi
    CI_IS_CRON=false
    if [[ "${TRAVIS_EVENT_TYPE}" = "cron" ]]; then
        CI_IS_CRON=true
    fi
    CI_TAG=${TRAVIS_TAG:-}
}

function sf_ci_printvars_travis() {
    printenv | grep "^CI[=_]"
    printenv | grep "^TRAVIS[=_]"
}
