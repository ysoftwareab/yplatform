#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://docs.cloudbees.com/docs/cloudbees-codeship/latest/pro-builds-and-configuration/environment-variables

function sf_ci_env_codeship() {
    [[ "${CI_NAME:-}" = "Codeship" ]] || return 0

    export CI=true
    CI_NAME=Codeship
    CI_PLATFORM=codeship
    CI_SERVER_HOST=codeship.com
    # CI_REPO_SLUG=${?????????????????}/${CI_REPO_NAME}
    # CI_REPO_SLUG=$(git remote -v 2>/dev/null | grep -oP "(?<=.com.).+" | grep -oP ".+(?= \(fetch\))" | head -n1 | sed "s/.git$//") # editorconfig-checker-disable-line
    CI_REPO_SLUG=${CI_REPO_NAME:-}
    CI_ROOT= # TODO

    CI_IS_CRON= # TODO
    CI_IS_PR=
    # codeship set CI_PR_NUMBER=0 for non-PR executions...
    [[ -z "${CI_PR_NUMBER:-}" ]] || [[ "${CI_PR_NUMBER:-}" = "0" ]] || CI_IS_PR=true
    [[ -z "${CI_PULL_REQUEST:-}" ]] || [[ "${CI_PR_NUMBER:-}" = "0" ]] || CI_IS_PR=true

    CI_JOB_ID=${CI_BUILD_ID_:-}
    CI_PIPELINE_ID=${CI_BUILD_NUMBER:-}
    CI_JOB_URL=https://app.codeship.com/projects/${CI_PROJECT_ID:-}/builds/${CI_JOB_ID}
    CI_PIPELINE_URL=${CI_BUILD_URL:-}

    CI_PR_URL=
    CI_PR_REPO_SLUG=
    CI_PR_GIT_HASH=
    CI_PR_GIT_BRANCH=
    [[ "${CI_IS_PR}" != "true" ]] || {
        # CI_PR_URL=https://github.com/${CI_REPO_SLUG}/pull/${CI_PR_NUMBER}
        CI_PR_URL=${CI_PULL_REQUEST:-}
        CI_PR_REPO_SLUG= # TODO
        CI_PR_GIT_HASH= # TODO
        CI_PR_GIT_BRANCH= # TODO
    }

    CI_GIT_HASH=${CI_COMMIT_ID:-}
    CI_GIT_BRANCH=${CI_BRANCH:-}
    CI_GIT_TAG= # TODO

    CI_DEBUG_MODE=${CI_DEBUG_MODE:-}
}

function sf_ci_printvars_codeship() {
    printenv | grep "^CI[=_]"
}
