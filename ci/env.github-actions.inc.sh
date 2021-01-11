#!/usr/bin/env bash
# shellcheck disable=SC2034
true

git config --global user.email "actions@github.com"
git config --global user.name "Github Actions CI"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
# travis -> github actions
# builds -> workflow runs
# jobs   -> job runs
# NOTE allow it to fail e.g. github-get-job-id depends on jq, and jq might nobe available
CI_JOB_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/github-get-job-id || true)
# CI_JOB_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}/checks?check_suite_id=FIXME"
CI_JOB_URL="https://github.com/${GITHUB_REPOSITORY}/runs/${CI_JOB_ID}?check_suite_focus=true"
CI_REPO_SLUG=${GITHUB_REPOSITORY}
CI_IS_PR=false
CI_PR_SLUG=
if [[ "${GITHUB_EVENT_NAME}" = "pull_request" ]]; then
    CI_IS_PR=true
    CI_PR_SLUG=$(${SUPPORT_FIRECLOUD_DIR}/bin/jq -r .github.event.pull_request.url ${GITHUB_EVENT_PATH})
fi
CI_IS_CRON=false
if [[ -z "${GITHUB_EVENT_NAME}" ]]; then
    CI_IS_CRON=true
fi
CI_TAG=
if [[ "${GITHUB_REF:-}" =~ ^refs/tags/ ]]; then
    CI_TAG=${GITHUB_REF#refs\/tags\/}
fi
export CI=true
