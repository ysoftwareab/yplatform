#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_sourcehut() {
    [[ "${CI_NAME:-}" = "sourcehut" ]] || return 0

    # FIXME sourcehut hasn't been fully tested. narrowing the scope
    [[ "${BUILD_REASON}" = "github-commit" ]] # only github webhooks
    [[ "${GITHUB_EVENT}" = "push" ]] # only push
    [[ ${GITHUB_REF} =~ ^refs/heads/ ]] # only branches

    CI_NAME=sourcehut
    CI_PLATFORM=sourcehut

    git config --global user.email "sourcehut@sourcehut.org"
    git config --global user.name "sourcehut"

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
    CI_JOB_ID=${JOB_ID}
    CI_JOB_URL=${JOB_URL}
    CI_PR_SLUG=
    CI_REPO_SLUG=${GITHUB_REPO}
    CI_IS_PR=false
    CI_IS_CRON=false
    CI_TAG= #TODO

    export CI=true
}
