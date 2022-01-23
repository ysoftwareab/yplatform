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
[[ -e ${UHOME}/.bashrc ]] || cat <<EOF >> ${UHOME}/.bashrc
# If not running interactively, don't do anything
[[ $- = *i* ]] || return
EOF
cat ${UHOME}/.bashrc | grep -q "\.bash_aliases" || cat <<EOF >> ${UHOME}/.bashrc
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[[ ! -f ~/.bash_aliases ]] || . ~/.bash_aliases
EOF
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.bashrc

cat <<EOF >> ${UHOME}/.bash_aliases
# poor-man version of sh/exe.inc.sh:sh_shellopts
OPTS_STATE="\$(set +o); \$(shopt -p)"
source ${YP_DIR}/bootstrap/brew-util/env.inc.sh
source ${YP_DIR}/sh/dev.inc.sh
# revert any shell options set in the scripts above
eval "\${OPTS_STATE}"; unset OPTS_STATE
EOF
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.bash_aliases

mkdir -p ${UHOME}/.ssh
chmod 700 ${UHOME}/.ssh
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.ssh

ln -sf /yplatform/sshconfig ${UHOME}/.ssh/yplatform
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.ssh/yplatform

cat <<EOF > ${UHOME}/.ssh/config
Include ~/.ssh/yplatform/config
EOF
chmod 600 ${UHOME}/.ssh/config
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.ssh/config

touch ${UHOME}/.sudo_as_admin_successful
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.sudo_as_admin_successful

# NOTE prefer to have dockerfiles/util/gitconfig.inc.sh look like ci/util/gitconfig.inc.sh
HOME_BAK="${HOME}"
HOME="${UHOME}"
source ${YP_DIR}/dockerfiles/util/gitconfig.inc.sh
HOME="${HOME_BAK}"
unset HOME_BAK
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/{.gitattributes_global,.gitconfig,.gitignore_global}
