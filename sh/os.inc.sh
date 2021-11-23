#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

ARCH=$(uname -m)
ARCH_SHORT=$(echo "${ARCH}" | grep -q "64" && echo "x64" || echo "x86")
ARCH_BIT=$(echo "${ARCH}" | grep -q "64" && echo "64" || echo "32")

OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
