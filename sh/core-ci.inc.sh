#!/usr/bin/env bash
# shellcheck disable=SC2034
true

[[ -z "${GITHUB_ACTIONS:-}" ]] || echo ::group::HOME
source ${SUPPORT_FIRECLOUD_DIR}/sh/core-ci-home.inc.sh
[[ -z "${GITHUB_ACTIONS:-}" ]] || echo ::envgroup::

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}
