#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

ARCH=$(uname -m)
# https://github.com/containerd/containerd/blob/f2c3122e9c6470c052318497899b290a5afc74a5/platforms/platforms.go#L88-L94
# https://github.com/BretFisher/multi-platform-docker-build
ARCH_NORMALIZED=$(echo "${ARCH}" | sed \
    -e "s|^aarch64$|arm64|" \
    -e "s|^arm64/v8$|arm64|" \
    -e "s|^armhf$|arm|" \
    -e "s|^arm64/v7$|arm|" \
    -e "s|^armel$|arm/v6|" \
    -e "s|^i386$|386|" \
    -e "s|^i686$|386|" \
    -e "s|^x86_64$|amd64|" \
    -e "s|^x86-64$|amd64|" \
)
ARCH_SHORT=$(echo "${ARCH}" | grep -q "64" && echo "x64" || echo "x86")
ARCH_BIT=$(echo "${ARCH}" | grep -q "64" && echo "64" || echo "32")

OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
