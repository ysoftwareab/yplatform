#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

# sync with  mk/git.inc.mk

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_BRANCH_SHORT=$(basename "${GIT_BRANCH}" 2>/dev/null || true)
GIT_COMMIT_MSG=$(git log -1 --format="%B" 2>/dev/null || true)
GIT_DESCRIBE=$(git describe --tags --first-parent --always --dirty 2>/dev/null || true)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null || true)
GIT_TAGS=$(git tag --points-at HEAD 2>/dev/null || true)

[[ -z "${SEMAPHORE_GIT_BRANCH:-}" ]] || {
    GIT_BRANCH=${SEMAPHORE_GIT_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${SEMAPHORE_GIT_BRANCH})
}

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}

GIT_REMOTE=$(git config branch.${GIT_BRANCH}.remote 2>/dev/null || true)
GIT_REMOTE_OR_ORIGIN=${GIT_REMOTE:-origin}
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)

GIT_REPO_HAS_CHANGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -v -e "^$$" && \
    echo true || echo false)
GIT_REPO_HAS_STAGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^[^ U\?]" && \
    echo true || echo false)
GIT_REPO_HAS_UNSTAGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^ [^ ]" && \
    echo true || echo false)
GIT_REPO_HAS_UNTRACKED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^\?\?" && \
    echo true || echo false)
GIT_REPO_HAS_CONFLICTS=$(git status --porcelain 2>/dev/null | grep -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
    echo true || echo false)
