#!/usr/bin/env bash

git config --global user.email "actions@github.com"
git config --global user.name "Github Actions CI"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
CI_JOB_ID=${GITHUB_ACTION}
CI_JOB_URL=https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME
CI_PR_SLUG=
if [[ "${GITHUB_EVENT_NAME}" = "pull_request" ]]; then
    CI_PR_SLUG=https://github.com/${GITHUB_REPOSITORY}/pull/$(jq -r .github.event.number ${GITHUB_EVENT_PATH})
fi
CI_REPO_SLUG=${GITHUB_REPOSITORY}
CI_IS_PR=false
if [[ "${GITHUB_EVENT_NAME}" = "pull_request" ]]; then
    CI_IS_PR=true
fi
CI_IS_CRON=false
if [[ "${GITHUB_EVENT_NAME}" = "" ]]; then
    CI_IS_CRON=true
fi
CI_TAG=
if [[ "${GITHUB_REF:-}" =~ "^refs/tags/" ]]; then
    CI_TAG=${GITHUB_REF#refs\/tags\/}
fi
export CI=true

# see https://github.com/actions/virtual-environments/issues/1811#issuecomment-713862592
brew tap | grep "^local/" | xargs brew untap
