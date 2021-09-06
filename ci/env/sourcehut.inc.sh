#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_sourcehut() {
    [[ "${CI_NAME:-}" = "sourcehut" ]] || return 0

    # TODO sourcehut hasn't been fully tested. narrowing the scope
    [[ "${BUILD_REASON}" =~ ^github ]] # only github webhooks
    [[ "${GITHUB_EVENT}" = "push" ]] || [[ "${GITHUB_EVENT}" = "pull_request" ]] # only commits and pull requests
    [[ ${GITHUB_REF} =~ ^refs/heads/ ]] || [[ ${GITHUB_REF} =~ ^refs/pull/ ]] # only branches and pull requests

    export CI=true # missing
    SF_CI_NAME=sourcehut
    SF_CI_PLATFORM=sourcehut
    SF_CI_SERVERT_HOST=sourcehut.org
    SF_CI_REPO_SLUG=${GITHUB_BASE_REPO:-${GITHUB_REPO:-}}
    SF_CI_ROOT=${HOME}

    SF_CI_IS_CRON=
    SF_CI_IS_PR=
    [[ "${BUILD_REASON:-}" != "github-pr" ]] || SF_CI_IS_PR=true

    SF_CI_JOB_ID=${JOB_ID:-}
    SF_CI_PIPELINE_ID=${SF_CI_JOB_ID}
    SF_CI_JOB_URL=${JOB_URL:-}
    SF_CI_PIPELINE_URL=${SF_CI_JOB_URL}

    SF_CI_PR_NUMBER=
    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        SF_CI_PR_NUMBER=${GITHUB_PR_NUMBER:-}
        SF_CI_PR_URL=https://github.com/${SF_CI_REPO_SLUG}/pull/${SF_CI_PR_NUMBER}
        SF_CI_PR_REPO_SLUG=https://github.com/${GITHUB_HEAD_REPO:-}
        SF_CI_PR_GIT_HASH= # TODO
        SF_CI_PR_GIT_BRANCH= # TODO
    }

    SF_CI_GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
    SF_CI_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    SF_CI_GIT_TAG=$(git tag --points-at HEAD 2>/dev/null || true)

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_sourcehut() {
    printenv_all | sort -u | grep \
        -e "^BUILD[=_]" \
        -e "^CI[=_]" \
        -e "^GITHUB[=_]" \
        -e "^JOB[=_]" \
        -e "^PATCHSET[=_]"
}

function sf_ci_known_env_sourcehut() {
    # see https://man.sr.ht/builds.sr.ht/
    cat <<EOF
JOB_ID
JOB_URL
BUILD_SUBMITTER
BUILD_REASON
BUILD_SUBMITTER
BUILD_REASON
PATCHSET_ID
PATCHSET_URL
EOF
    # see https://man.sr.ht/dispatch.sr.ht/github.md
    cat <<EOF
GITHUB_DELIVERY
GITHUB_EVENT
GITHUB_REF
GITHUB_REPO
GITHUB_PR_NUMBER
GITHUB_PR_TITLE
GITHUB_PR_BODY
GITHUB_BASE_REPO
GITHUB_HEAD_REPO
EOF
}
