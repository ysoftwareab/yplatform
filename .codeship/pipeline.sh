#!/usr/bin/env bash
set -euo pipefail

CI_IS_PR=false
if [[ -n "${CI_PR_NUMBER:-}" || -n "${CI_PULL_REQUEST:-}" ]]; then
    CI_IS_PR=true
fi

# in PRs, only run ux-minimal
[[ "${CI_IS_PR}" = "true" ]] && [[ "${CI_STEP_NAME}" = "ux-minimal" ]] || exit 0

source repo/ci.sh/pipeline.install.sh
source repo/ci.sh/pipeline.script.sh

# deploy only version tags
GIT_TAG=$(git tag -l --points-at HEAD | head -1)
echo "${GIT_TAG}" | grep -q "^v[0-9]\+\.[0-9]\+\.[0-9]\+$" || exit 0

source repo/ci.sh/pipeline.deploy.sh
