#!/usr/bin/env bash
set -euo pipefail

CI=${CI:-}
[ "${CI}" = "1" ] && CI=true || true

V=${V:-${VERBOSE:-}}
VERBOSE=${V}
[ "${VERBOSE}" = "1" ] && VERBOSE=true || true

# [ "${CI}" != "true" ] || {
#     # VERBOSE=true
# }

[ "${VERBOSE}" != "true" ] || set -x

OS=$(uname | tr "[A-Z]" "[a-z]")
OS_SHORT=$(echo ${OS} | sed "s/^\([a-z]\+\).*/\1/g")
ARCH=$(uname -m)
ARCH_SHORT=$(uname -m | grep -q "x86_64" && echo "x64" || echo "x86")
ARCH_BIT=$(uname -m | grep -q "x86_64" && echo "64" || echo "32")

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT=$(basename ${GIT_BRANCH})
