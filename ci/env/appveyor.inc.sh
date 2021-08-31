#!/usr/bin/env bash
# shellcheck disable=SC2034
true

# see https://www.appveyor.com/docs/environment-variables/

function sf_ci_env_appveyor() {
    false || \
        [[ "${APPVEYOR:-}" = "True" ]] || \
        [[ "${APPVEYOR:-}" = "true" ]] || \
        return 0

    if printenv | grep -q "=True$"; then
        # normalize 'True' to 'true'
        while read -r NO_XARGS_R; do
            [[ -n "${NO_XARGS_R}" ]] || continue;
            eval "export ${NO_XARGS_R}=true"
        done < <(printenv | grep "=True$" | sed "s/=.*//g")
    fi

    [[ "${APPVEYOR_REPO_PROVIDER:-}" = "gitHub" ]]

    export CI=true
    SF_CI_NAME=Appveyor
    SF_CI_PLATFORM=appveyor
    SF_CI_SERVER_HOST=${APPVEYOR_URL:-ci.appveyor.com}
    SF_CI_SERVER_HOST=${SF_CI_SERVER_HOST#*://}
    SF_CI_REPO_SLUG=${APPVEYOR_REPO_NAME:-}
    SF_CI_ROOT=${APPVEYOR_BUILD_FOLDER}

    SF_CI_IS_CRON=${APPVEYOR_SCHEDULED_BUILD:-}
    SF_CI_IS_PR=
    [[ -z "${APPVEYOR_PULL_REQUEST_NUMBER:-}" ]] || SF_CI_IS_PR=true

    SF_CI_JOB_ID=${APPVEYOR_JOB_ID:-}
    SF_CI_PIPELINE_ID=${APPVEYOR_BUILD_NUMBER:-}
    # SF_CI_JOB_URL=https://${SF_CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/builds/${SF_CI_JOB_ID} # editorconfig-checker-disable-line
    SF_CI_JOB_URL=https://${SF_CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/build/job/${SF_CI_JOB_ID} # editorconfig-checker-disable-line
    SF_CI_PIPELINE_URL=https://${SF_CI_SERVER_HOST}/project/${APPVEYOR_ACCOUNT_NAME:-}/${APPVEYOR_PROJECT_SLUG:-}/build/${SF_CI_PIPELINE_ID} # editorconfig-checker-disable-line

    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        SF_CI_REPO_URL=https://github.com/${SF_CI_REPO_SLUG}/pull/${APPVEYOR_PULL_REQUEST_NUMBER:-}
        SF_CI_PR_REPO_SLUG=${APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME:-}
        SF_CI_PR_GIT_HASH=${APPVEYOR_PULL_REQUEST_HEAD_COMMIT:-}
        SF_CI_PR_GIT_BRANCH=${APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH:-}
    }

    SF_CI_GIT_HASH=${APPVEYOR_REPO_COMMIT:-}
    SF_CI_GIT_BRANCH=${APPVEYOR_REPO_BRANCH:-}
    SF_CI_GIT_TAG=${APPVEYOR_REPO_TAG_NAME:-}

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_appveyor() {
    printenv_all | sort -u | grep \
        -e "^APPVEYOR[=_]" \
        -e "^CI[=_]" \
        -e "^CONFIGURATION$" \
        -e "^PLATFORM$"
}

function sf_ci_known_env_appveyor() {
    cat <<EOF
CI
APPVEYOR
APPVEYOR_URL
APPVEYOR_API_URL
APPVEYOR_ACCOUNT_NAME
APPVEYOR_PROJECT_ID
APPVEYOR_PROJECT_NAME
APPVEYOR_PROJECT_SLUG
APPVEYOR_BUILD_FOLDER
APPVEYOR_BUILD_ID
APPVEYOR_BUILD_NUMBER
APPVEYOR_BUILD_VERSION
APPVEYOR_BUILD_WORKER_IMAGE
APPVEYOR_PULL_REQUEST_NUMBER
APPVEYOR_PULL_REQUEST_TITLE
APPVEYOR_PULL_REQUEST_HEAD_REPO_NAME
APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH
APPVEYOR_PULL_REQUEST_HEAD_COMMIT
APPVEYOR_JOB_ID
APPVEYOR_JOB_NAME
APPVEYOR_JOB_NUMBER
APPVEYOR_REPO_PROVIDER
APPVEYOR_REPO_SCM
APPVEYOR_REPO_NAME
APPVEYOR_REPO_BRANCH
APPVEYOR_REPO_TAG
APPVEYOR_REPO_TAG_NAME
APPVEYOR_REPO_COMMIT
APPVEYOR_REPO_COMMIT_AUTHOR
APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL
APPVEYOR_REPO_COMMIT_TIMESTAMP
APPVEYOR_REPO_COMMIT_MESSAGE
APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED
APPVEYOR_SCHEDULED_BUILD
APPVEYOR_FORCED_BUILD
APPVEYOR_RE_BUILD
APPVEYOR_RE_RUN_INCOMPLETE
PLATFORM
CONFIGURATION
APPVEYOR_ARTIFACT_UPLOAD_TIMEOUT
APPVEYOR_FILE_DOWNLOAD_TIMEOUT
APPVEYOR_REPOSITORY_SHALLOW_CLONE_TIMEOUT
APPVEYOR_CACHE_ENTRY_UPLOAD_DOWNLOAD_TIMEOUT
APPVEYOR_CACHE_SKIP_RESTORE
APPVEYOR_CACHE_SKIP_SAVE
APPVEYOR_WAP_ARTIFACT_NAME
APPVEYOR_WAP_SKIP_ACLS
APPVEYOR_BUILD_WORKER_IMAGE
APPVEYOR_SKIP_FINALIZE_ON_EXIT
APPVEYOR_SAVE_CACHE_ON_ERROR
APPVEYOR_ACS_DEPLOYMENT_UPGRADE_MODE
APPVEYOR_IGNORE_COMMIT_FILTERING_ON_TAG
EOF
}
