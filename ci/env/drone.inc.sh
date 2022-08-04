#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_ci_env_drone() {
    [[ "${DRONE:-}" = "true" ]] || return 0

    export CI=true
    YP_CI_NAME=Drone
    YP_CI_PLATFORM=drone
    YP_CI_SERVER_HOST=drone.io
    YP_CI_REPO_SLUG=${DRONE_REPO:-}
    YP_CI_ROOT=${DRONE_WORKSPACE}

    YP_CI_IS_CRON= # TODO
    YP_CI_IS_PR=
    [[ -z "${DRONE_PULL_REQUEST:-}" ]] || YP_CI_IS_PR=true

    YP_CI_JOB_ID= # TODO
    YP_CI_PIPELINE_ID=${DRONE_BUILD_NUMBER:-}
    YP_CI_JOB_URL= # TODO
    YP_CI_PIPELINE_URL=${DRONE_BUILD_LINK:-}

    YP_CI_PR_NUMBER=
    YP_CI_PR_URL=
    YP_CI_PR_REPO_SLUG=
    YP_CI_PR_GIT_HASH=
    YP_CI_PR_GIT_BRANCH=
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        YP_CI_PR_NUMBER=${DRONE_PULL_REQUEST:-}
        YP_CI_PR_URL=https://github.com/${YP_CI_REPO_SLUG}/pull/${YP_CI_PR_NUMBER}
        YP_CI_PR_REPO_SLUG= # TODO
        YP_CI_PR_GIT_HASH= # TODO
        YP_CI_PR_GIT_BRANCH=${DRONE_SOURCE_BRANCH:-}
    }

    YP_CI_GIT_HASH=${DRONE_COMMIT_SHA:-}
    YP_CI_GIT_BRANCH=${DRONE_TARGET_BRANCH:-${DRONE_BRANCH:-}}
    YP_CI_GIT_TAG=${DRONE_TAG:-}

    YP_CI_DEBUG_MODE=${YP_CI_DEBUG_MODE:-}
}

function yp_ci_printvars_drone() {
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^DRONE[=_]" \
        -e "^GIT_"
}

function yp_ci_known_env_drone() {
    # see https://docs.drone.io/pipeline/environment/reference/
    cat <<EOF
CI
DRONE
DRONE_BRANCH
DRONE_BUILD_ACTION
DRONE_BUILD_CREATED
DRONE_BUILD_EVENT
DRONE_BUILD_FINISHED
DRONE_BUILD_LINK
DRONE_BUILD_NUMBER
DRONE_BUILD_PARENT
DRONE_BUILD_STARTED
DRONE_BUILD_STATUS
DRONE_CALVER
DRONE_COMMIT
DRONE_COMMIT_AFTER
DRONE_COMMIT_AUTHOR
DRONE_COMMIT_AUTHOR_AVATAR
DRONE_COMMIT_AUTHOR_EMAIL
DRONE_COMMIT_AUTHOR_NAME
DRONE_COMMIT_BEFORE
DRONE_COMMIT_BRANCH
DRONE_COMMIT_LINK
DRONE_COMMIT_MESSAGE
DRONE_COMMIT_REF
DRONE_COMMIT_SHA
DRONE_DEPLOY_TO
DRONE_FAILED_STAGES
DRONE_FAILED_STEPS
DRONE_GIT_HTTP_URL
DRONE_GIT_SSH_URL
DRONE_PULL_REQUEST
DRONE_PULL_REQUEST_TITLE
DRONE_REMOTE_URL
DRONE_REPO
DRONE_REPO_BRANCH
DRONE_REPO_LINK
DRONE_REPO_NAME
DRONE_REPO_NAMESPACE
DRONE_REPO_OWNER
DRONE_REPO_PRIVATE
DRONE_REPO_SCM
DRONE_REPO_VISIBILITY
DRONE_SEMVER
DRONE_SEMVER_BUILD
DRONE_SEMVER_ERROR
DRONE_SEMVER_MAJOR
DRONE_SEMVER_MINOR
DRONE_SEMVER_PATCH
DRONE_SEMVER_PRERELEASE
DRONE_SEMVER_SHORT
DRONE_SOURCE_BRANCH
DRONE_STAGE_ARCH
DRONE_STAGE_DEPENDS_ON
DRONE_STAGE_FINISHED
DRONE_STAGE_KIND
DRONE_STAGE_MACHINE
DRONE_STAGE_NAME
DRONE_STAGE_NUMBER
DRONE_STAGE_OS
DRONE_STAGE_STARTED
DRONE_STAGE_STATUS
DRONE_STAGE_TYPE
DRONE_STAGE_VARIANT
DRONE_STEP_NAME
DRONE_STEP_NUMBER
DRONE_SYSTEM_HOST
DRONE_SYSTEM_HOSTNAME
DRONE_SYSTEM_PROTO
DRONE_SYSTEM_VERSION
DRONE_TAG
DRONE_TARGET_BRANCH
EOF
    # undocumented but observed
    cat <<EOF
CI_BUILD_CREATED
CI_BUILD_EVENT
CI_BUILD_FINISHED
CI_BUILD_LINK
CI_BUILD_NUMBER
CI_BUILD_STARTED
CI_BUILD_STATUS
CI_COMMIT_AUTHOR
CI_COMMIT_AUTHOR_AVATAR
CI_COMMIT_AUTHOR_EMAIL
CI_COMMIT_AUTHOR_NAME
CI_COMMIT_BRANCH
CI_COMMIT_MESSAGE
CI_COMMIT_REF
CI_COMMIT_SHA
CI_PARENT_BUILD_NUMBER
CI_REMOTE_URL
CI_REPO
CI_REPO_LINK
CI_REPO_NAME
CI_REPO_PRIVATE
CI_REPO_REMOTE
DRONE_BUILD_DEBUG
DRONE_BUILD_TRIGGER
DRONE_CARD_PATH
DRONE_CALVER_SHORT
DRONE_CALVER_MAJOR_MINOR
DRONE_CALVER_MAJOR
DRONE_CALVER_MINOR
DRONE_CALVER_MICRO
DRONE_CALVER_MODIFIER
DRONE_DEPLOY_ID
DRONE_DOCKER_NETWORK_ID
DRONE_DOCKER_VOLUME_ID
DRONE_STAGE_VERSION
DRONE_WORKSPACE
DRONE_WORKSPACE_BASE
GIT_AUTHOR_EMAIL
GIT_AUTHOR_NAME
GIT_COMMITTER_EMAIL
GIT_COMMITTER_NAME
GIT_TERMINAL_PROMPT
EOF
    # our own GIT_* env vars
    cat <<EOF
GIT_BRANCH
GIT_BRANCH_SHORT
GIT_COMMIT_MSG
GIT_DESCRIBE
GIT_HASH
GIT_HASH_SHORT
GIT_REMOTE
GIT_REMOTE_OR_ORIGIN
GIT_REPO_HAS_CHANGED_FILES
GIT_REPO_HAS_CONFLICTS
GIT_REPO_HAS_STAGED_FILES
GIT_REPO_HAS_UNSTAGED_FILES
GIT_REPO_HAS_UNTRACKED_FILES
GIT_ROOT
GIT_TAGS
EOF
}
