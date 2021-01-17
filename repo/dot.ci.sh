#!/usr/bin/env bash
# shellcheck disable=SC2034
true

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
[[ -e ${SUPPORT_FIRECLOUD_DIR}/Makefile ]] || \
    git submodule update --init --recursive ${SUPPORT_FIRECLOUD_DIR}
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

## to override an existing phase implementation
# function ci_run_<phase>() {
# }

## to wrap an existing phase implementation
# eval "original_$(declare -f ci_run_<phase>)"
# function ci_run_<phase>() {
#   ...
#   original_ci_run_<phase>
#   ...
# }
#

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
