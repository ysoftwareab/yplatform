#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

GITHUB_JOB_NAME=${GITHUB_JOB_NAME:-test}
GITHUB_JOB_LOWER=$(echo "${GITHUB_JOB}" | tr "[:upper:]" "[:lower:]")
source .ci.${GITHUB_JOB_LOWER}.sh
