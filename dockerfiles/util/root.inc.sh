#!/usr/bin/env bash
set -euo pipefail

# create same vars as in user.inc.sh

# shellcheck disable=SC2034
UID_INDEX=0
# shellcheck disable=SC2034
GID_INDEX=0
# shellcheck disable=SC2034
GNAME_REAL=root
# shellcheck disable=SC2034
UHOME=${HOME}

source ${YP_DIR}/dockerfiles/util/userconfig.inc.sh
source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh

unset GID_INDEX
unset GNAME_REAL
unset UHOME
unset UID_INDEX
