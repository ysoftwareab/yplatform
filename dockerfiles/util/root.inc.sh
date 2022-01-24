#!/usr/bin/env bash
set -euo pipefail

# create same vars as in user.inc.sh

UID_INDEX_BAK=${UID_INDEX:-}
GID_INDEX_BAK=${GID_INDEX:-}
GNAME_REAL_BAK=${GNAME_REAL:-}
UHOME_BAK=${UHOME:-}

UID_INDEX=0
GID_INDEX=0
GNAME_REAL=root
UHOME=$(eval echo "~root")

source ${YP_DIR}/dockerfiles/util/userconfig.inc.sh
source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh

UID_INDEX=${UID_INDEX_BAK:-}
GID_INDEX=${GID_INDEX_BAK:-}
GNAME_REAL=${GNAME_REAL_BAK:-}
UHOME=${UHOME_BAK:-}

unset GID_INDEX_BAK
unset GNAME_REAL_BAK
unset UHOME_BAK
unset UID_INDEX_BAK
