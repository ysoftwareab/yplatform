#!/usr/bin/env bash

git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"

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
