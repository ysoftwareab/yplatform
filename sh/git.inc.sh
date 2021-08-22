#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_BRANCH_SHORT=$(basename "${GIT_BRANCH}" 2>/dev/null || true)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null || true)
GIT_REMOTE=$(git config branch.${GIT_BRANCH}.remote 2>/dev/null || true)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
GIT_TAGS=$(git describe --exact-match --tags HEAD 2>/dev/null || true)
