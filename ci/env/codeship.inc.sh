#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_codeship() {
    [[ "${CI_NAME:-}" = "codeship" ]] || return 0

    export CI=true
    YP_CI_NAME=codeship
    YP_CI_PLATFORM=codeship
    YP_CI_SERVER_HOST=codeship.com
    # YP_CI_REPO_SLUG=${?????????????????}/${CI_REPO_NAME}
    # YP_CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep -oP "(?<=.com.).+" | grep -oP ".+(?= \(fetch\))" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
    YP_CI_REPO_SLUG=${CI_REPO_NAME:-}
    YP_CI_ROOT= # TODO

    YP_CI_IS_CRON= # TODO
    YP_CI_IS_PR=
    # codeship set YP_CI_PR_NUMBER=0 for non-PR executions...
    [[ -z "${CI_PR_NUMBER:-}" ]] || [[ "${CI_PR_NUMBER:-}" = "0" ]] || YP_CI_IS_PR=true
    [[ -z "${CI_PULL_REQUEST:-}" ]] || [[ "${CI_PR_NUMBER:-}" = "0" ]] || YP_CI_IS_PR=true

    YP_CI_JOB_ID=${CI_BUILD_ID:-}
    YP_CI_PIPELINE_ID=${CI_BUILD_NUMBER:-}
    YP_CI_JOB_URL=https://app.codeship.com/projects/${CI_PROJECT_ID:-}/builds/${YP_CI_JOB_ID}
    YP_CI_PIPELINE_URL=${CI_BUILD_URL:-}

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        YP_CI_PR_NUMBER= # TODO
        # YP_CI_PR_URL=https://github.com/${CI_REPO_SLUG}/pull/${YP_CI_PR_NUMBER}
        YP_CI_PR_URL=${CI_PULL_REQUEST:-}
        YP_CI_PR_REPO_SLUG= # TODO
        YP_CI_PR_GIT_HASH= # TODO
        YP_CI_PR_GIT_BRANCH= # TODO
    }

    YP_CI_GIT_HASH=${CI_COMMIT_ID:-}
    YP_CI_GIT_BRANCH=${CI_BRANCH:-}
    YP_CI_GIT_TAG= # TODO

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
}

function yp_ci_printvars_codeship() {
    printenv_all | sort -u | grep \
        -e "^CI[=_]"
}

function yp_ci_known_env_codeship() {
    # see https://docs.cloudbees.com/docs/cloudbees-codeship/latest/pro-builds-and-configuration/environment-variables
    cat <<EOF
CI
CI_BRANCH
CI_BUILD_APPROVED
CI_BUILD_ID
CI_COMMITTER_EMAIL
CI_COMMITTER_NAME
CI_COMMITTER_USERNAME
CI_COMMIT_DESCRIPTION
CI_COMMIT_ID
CI_COMMIT_MESSAGE
CI_NAME
CI_PROJECT_ID
CI_REPO_NAME
CI_STRING_TIME
CI_TIMESTAMP
CI_PR_NUMBER
CI_PULL_REQUEST
EOF
    # undocumented but observed
    cat <<EOF
EOF
}
