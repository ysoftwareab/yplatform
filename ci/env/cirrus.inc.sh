#!/usr/bin/env bash
# shellcheck disable=SC2034
true

CI_NAME="Cirrus CI"
CI_PLATFORM=cirrus

git config --global user.email "${CI_PLATFORM}@cirrus-ci.com"
git config --global user.name "${CI_NAME}"

CI_JOB_ID=${CIRRUS_BUILD_ID}
CI_JOB_URL="https://cirrus-ci.com/build/${CIRRUS_BUILD_ID}"
CI_PR_SLUG=
if [[ -n "${CIRRUS_PR:-}" ]]; then
    CI_PR_NUMBER=${CIRRUS_PR}
    CI_PR_SLUG=https://github.com/${CIRRUS_REPO_FULL_NAME}/pull/${CIRRUS_PR}
    unset CI_PR_NUMBER
fi
CI_REPO_SLUG=${CIRRUS_REPO_FULL_NAME}
CI_IS_PR=false
if [[ -n "${CIRRUS_PR:-}" ]]; then
    CI_IS_PR=true
fi
CI_IS_CRON=false
if [[ -n "${CIRRUS_CRON:-}" ]]; then
    CI_IS_CRON=true
fi
CI_TAG=${CIRRUS_TAG:-}
