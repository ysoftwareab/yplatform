#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://docs-staging.travis-ci.com/user/environment-variables/#default-environment-variables

function sf_ci_env_travis() {
    [[ "${TRAVIS:-}" = "true" ]] || return 0

    export CI=true
    CI_NAME="Travis CI"
    CI_PLATFORM=travis
    CI_SERVER_HOST=travis-ci.org
    CI_REPO_SLUG=${TRAVIS_REPO_SLUG:-}
    CI_ROOT=${TRAVIS_BUILD_DIR:-}

    CI_IS_CRON=false
    [[ "${TRAVIS_EVENT_TYPE}" != "cron" ]] || CI_IS_CRON=true
    CI_IS_PR=false
    [[ "${TRAVIS_EVENT_TYPE}" != "pull_request" ]] || CI_IS_PR=true

    CI_JOB_ID=${TRAVIS_JOB_ID:}
    CI_PIPELINE_ID=${TRAVIS_BUILD_NUMBER:-}
    CI_JOB_URL=${TRAVIS_JOB_WEB_URL:-}
    CI_PIPELINE_URL=${TRAVIS_BUILD_WEB_URL:-}

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL=https://github.com/${CI_REPO_SLUG}/pull/${TRAVIS_PULL_REQUEST:-}
        CI_PR_REPO_SLUG=${TRAVIS_PULL_REQUEST_SLUG:-}
        CI_PR_GIT_HASH=${TRAVIS_PULL_REQUEST_SHA:-}
        CI_PR_GIT_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH:-}
    }

    CI_GIT_HASH=${TRAVIS_COMMIT:-}
    CI_GIT_BRANCH=${TRAVIS_BRANCH:-}
    CI_GIT_TAG=${TRAVIS_TAG:-}

    CI_DEBUG_MODE=${TRAVIS_DEBUG_MODE:-}
}

function sf_ci_printvars_travis() {
    printenv | grep "^CI[=_]"
    printenv | grep "^TRAVIS[=_]"
}
