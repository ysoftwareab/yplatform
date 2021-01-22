#!/usr/bin/env bash
# shellcheck disable=SC2034
true

source ${SUPPORT_FIRECLOUD_DIR}/sh/core-ci-home.inc.sh

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
