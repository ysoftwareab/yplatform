#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_sourcehut() {
    [[ "${SF_CI_NAME:-}" = "sourcehut" ]] || return 0

    # TODO sourcehut hasn't been fully tested. narrowing the scope
    [[ "${BUILD_REASON}" = "github-commit" ]] # only github webhooks
    [[ "${GITHUB_EVENT}" = "push" ]] # only push
    [[ ${GITHUB_REF} =~ ^refs/heads/ ]] # only branches

    export CI=true # missing
    SF_CI_NAME=sourcehut
    SF_CI_PLATFORM=sourcehut
    SF_CI_SERVERT_HOST=sourcehut.org
    SF_CI_REPO_SLUG=
    SF_CI_ROOT=${HOME}

    SF_CI_IS_CRON=
    SF_CI_IS_PR= # TODO

    SF_CI_JOB_ID=${JOB_ID:-}
    SF_CI_PIPELINE_ID=${SF_CI_JOB_ID}
    SF_CI_JOB_URL=${JOB_URL:-}
    SF_CI_PIPELINE_URL=${SF_CI_JOB_URL}

    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        SF_CI_PR_URL= # TODO
        SF_CI_PR_REPO_SLUG= # TODO
        SF_CI_PR_GIT_HASH= # TODO
        SF_CI_PR_GIT_BRANCH= # TODO
    }

    SF_CI_GIT_HASH= # TODO
    SF_CI_GIT_BRANCH # TODO
    SF_CI_GIT_TAG= # TODO

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_sourcehut() {
    # CI is actually missing
    printenv | grep \
        -e "^BUILD[=_]" \
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
    # undocumented but observed
    cat <<EOF
GITHUB_DELIVERY
GITHUB_EVENT
GITHUB_REF
GITHUB_REPO
EOF
}
