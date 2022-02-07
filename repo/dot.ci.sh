#!/usr/bin/env bash
# shellcheck disable=SC2034
true

YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/yplatform" >/dev/null && pwd)"
[[ -e ${YP_DIR}/Makefile ]] || \
    git submodule update --init --recursive ${YP_DIR}
source ${YP_DIR}/sh/common.inc.sh

## see bootstrap/README.md
# export YP_LOG_BOOTSTRAP=true
# export YP_PRINTENV_BOOTSTRAP=true
# export YP_SKIP_SUDO_BOOTSTRAP=true
# export YP_SKIP_BREW_BOOTSTRAP=true

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

source "${YP_DIR}/repo/dot.ci.sh.yp"
