#!/usr/bin/env bash

git config --global user.email "codeship@codeship.com"
git config --global user.name "CodeShip"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
CI_JOB_ID=${CI_BUILD_ID}
CI_JOB_URL=https://app.codeship.com/projects/${CI_PROJECT_ID}/builds/${CI_BUILD_ID}
CI_PR_SLUG= #TODO
CI_REPO_SLUG=${?????????????????}/${CI_REPO_NAME}
CI_IS_PR=false
if [[ -n "${CI_PR_NUMBER:-}" || -n "${CI_PULL_REQUEST:-}" ]]; then
    CI_IS_PR=true
fi
CI_IS_CRON= # TODO
CI_TAG= #TODO
