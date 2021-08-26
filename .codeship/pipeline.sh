#!/usr/bin/env bash
set -euo pipefail

CI_IS_PR=false
if [[ -n "${CI_PR_NUMBER:-}" || -n "${CI_PULL_REQUEST:-}" ]]; then
    CI_IS_PR=true
fi

# in PRs, only run ux-minimal
if [[ "${CI_IS_PR}" = "true" ]]; then
    [[ "${CI_STEP_NAME}" = "ux-minimal" ]] || exit 0
fi

source ci/pipeline.script.sh

# deploy only version tags
GIT_TAG=$(git tag -l --points-at HEAD | head -1)
if [[ -n "${GIT_TAG}" ]]; then
    echo "${GIT_TAG}" | grep -q "^v[0-9]\+\.[0-9]\+\.[0-9]\+$" || exit 0
fi

source ci/pipeline.deploy.sh
