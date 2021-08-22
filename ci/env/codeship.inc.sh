#!/usr/bin/env bash
# shellcheck disable=SC2034
true

CI_PLATFORM=codeship

git config --global user.email "${CI_PLATFORM}@codeship.com"
git config --global user.name "${CI_NAME}"

CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
CI_JOB_ID=${CI_BUILD_ID}
CI_JOB_URL=https://app.codeship.com/projects/${CI_PROJECT_ID}/builds/${CI_BUILD_ID}
CI_PR_SLUG= # needs CI_REPO_SLUG
# CI_REPO_SLUG=${?????????????????}/${CI_REPO_NAME}
CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep -oP "(?<=.com.).+" | grep -oP ".+(?= \(fetch\))" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
CI_IS_PR=false
if [[ -n "${CI_PR_NUMBER:-}" || -n "${CI_PULL_REQUEST:-}" ]]; then
    CI_IS_PR=true
fi
CI_IS_CRON=false
CI_TAG= #TODO

# TODO assuming github.com
CI_PR_SLUG=https://github.com/${CI_REPO_SLUG}/pull/${CI_PR_NUMBER}
