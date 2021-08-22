#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

ARCH=$(uname -m)
ARCH_BIT=$(echo "${ARCH}" | grep -q "x86_64" && echo "64" || echo "32")
# FIXME should handle arm64 aarch64 others?! Same in build.mk/core.inc.mk/os.inc.mk
ARCH_SHORT=$(echo "${ARCH}" | grep -q "x86_64" && echo "x64" || echo "x86")

OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
