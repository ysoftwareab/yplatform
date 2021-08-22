#!/usr/bin/env bash
# shellcheck disable=SC2034
true

source ${SUPPORT_FIRECLOUD_DIR}/sh/ci-home.inc.sh

[[ -z "${SEMAPHORE_GIT_BRANCH:-}" ]] || {
    GIT_BRANCH=${SEMAPHORE_GIT_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${SEMAPHORE_GIT_BRANCH})
}

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
