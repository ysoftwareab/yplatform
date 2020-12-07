#!/usr/bin/env bash

git config --global user.email "gitlab@gitlab.com"
git config --global user.name "Gitlab CI"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
# CI_JOB_ID=
# CI_JOB_URL=
CI_REPO_SLUG=${CI_PROJECT_PATH}
CI_IS_PR=$([[ -n "${CI_MERGE_REQUEST_ID:-}" ]] && echo true || echo false)
CI_IS_CRON=$([[ "${CI_PIPELINE_SOURCE}" = "schedule" ]] && echo true || echo false)
# CI_TAG=
