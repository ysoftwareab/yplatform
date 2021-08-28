#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_sourcehut() {
    [[ "${CI_NAME:-}" = "sourcehut" ]] || return 0

    # TODO sourcehut hasn't been fully tested. narrowing the scope
    [[ "${BUILD_REASON}" = "github-commit" ]] # only github webhooks
    [[ "${GITHUB_EVENT}" = "push" ]] # only push
    [[ ${GITHUB_REF} =~ ^refs/heads/ ]] # only branches

    export CI=true # missing
    CI_NAME=sourcehut
    CI_PLATFORM=sourcehut
    CI_SERVERT_HOST=sourcehut.org
    CI_REPO_SLUG=
    CI_ROOT=${HOME}

    CI_IS_CRON=
    CI_IS_PR= # TODO

    CI_JOB_ID=${JOB_ID:-}
    CI_PIPELINE_ID=${CI_JOB_ID}
    CI_JOB_URL=${JOB_URL:-}
    CI_PIPELINE_URL=${CI_JOB_URL}

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        CI_PR_URL= # TODO
        CI_PR_REPO_SLUG= # TODO
        CI_PR_GIT_HASH= # TODO
        CI_PR_GIT_BRANCH= # TODO
    }

    CI_GIT_HASH= # TODO
    CI_GIT_BRANCH # TODO
    CI_GIT_TAG= # TODO

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
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
