#!/usr/bin/env bash
# shellcheck disable=SC2034
true

CI_NAME=AppVeyor
CI_PLATFORM=appveyor

git config --global user.email "${CI_PLATFORM}@appveyor.com"
git config --global user.name "${CI_NAME}"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
CI_JOB_ID=${APPVEYOR_JOB_ID}
CI_JOB_URL=https://ci.appveyor.com/project/${APPVEYOR_ACCOUNT_NAME}/${APPVEYOR_PROJECT_SLUG}/builds/${CI_JOB_ID}
CI_PR_SLUG=${APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME:-}
CI_REPO_SLUG=${APPVEYOR_REPO_NAME}
CI_IS_PR=false
if [[ -n "${APPVEYOR_PULL_REQUEST_NUMBER:-}" ]]; then
    CI_IS_PR=true
fi
CI_IS_CRON=${APPVEYOR_SCHEDULED_BUILD:-}
CI_TAG=${APPVEYOR_REPO_TAG_NAME:-}
