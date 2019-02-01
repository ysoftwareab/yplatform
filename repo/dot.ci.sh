#!/usr/bin/env bash

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

# function ci_run_<step>() {
# }

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
