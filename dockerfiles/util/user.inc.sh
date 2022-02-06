#!/usr/bin/env bash
set -euo pipefail

GID_INDEX=$((GID_INDEX + 1))
cat /etc/group | cut -d":" -f3 | grep -q "^${GID_INDEX}$" || {
    ${YP_DIR}/bin/linux-addgroup --gid ${GID_INDEX} ${GNAME}
}
GNAME_REAL=$(getent group ${GID_INDEX} | cut -d: -f1)

UHOME=/home/${UNAME}
UID_INDEX=$((UID_INDEX + 1))
${YP_DIR}/bin/linux-adduser \
    --uid ${UID_INDEX} \
    --ingroup ${GNAME_REAL} \
    --home ${UHOME} \
    --shell /bin/sh \
    --disabled-password \
    ${UNAME}
! cat /etc/group | cut -d":" -f1 | grep -q "^sudo$" || ${YP_DIR}/bin/linux-adduser2group ${UNAME} sudo
echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:${UNAME} !env_reset" >> /etc/sudoers
echo "Defaults:${UNAME} !secure_path" >> /etc/sudoers

# POST-BOOTSTRAP
source ${YP_DIR}/dockerfiles/util/userconfig.inc.sh
source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh
