#!/usr/bin/env bash

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/bin/common.inc.sh

# function travis_run_<step>() {
# }

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.travis.sh.sf"
