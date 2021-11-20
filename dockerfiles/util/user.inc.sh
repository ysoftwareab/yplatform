#!/usr/bin/env bash
set -euo pipefail

GID_INDEX=$((GID_INDEX + 1))
cat /etc/group | cut -d":" -f3 | grep -q "^${GID_INDEX}$" || {
    ${YP_DIR}/bin/linux-addgroup --gid ${GID_INDEX} ${GNAME}
}
GNAME_REAL=$(getent group ${GID_INDEX} | cut -d: -f1)

UID_INDEX=$((UID_INDEX + 1))
${YP_DIR}/bin/linux-adduser \
    --uid ${UID_INDEX} \
    --ingroup ${GNAME_REAL} \
    --home /home/${UNAME} \
    --shell /bin/sh \
    --disabled-password \
    ${UNAME}
! cat /etc/group | cut -d":" -f1 | grep -q "^sudo$" || ${YP_DIR}/bin/linux-adduser2group ${UNAME} sudo
echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:${UNAME} !env_reset" >> /etc/sudoers
echo "Defaults:${UNAME} !secure_path" >> /etc/sudoers

# POST-BOOTSTRAP
[[ -e /home/${UNAME}/.bashrc ]] || cat <<EOF >> /home/${UNAME}/.bashrc
# If not running interactively, don't do anything
[[ $- = *i* ]] || return
EOF
cat /home/${UNAME}/.bashrc | grep -q "\.bash_aliases" || cat <<EOF >> /home/${UNAME}/.bashrc
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[[ ! -f ~/.bash_aliases ]] || . ~/.bash_aliases
EOF
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.bashrc

cat <<EOF >> /home/${UNAME}/.bash_aliases
# poor-man version of sh/exe.inc.sh:sh_shellopts
OPTS_STATE="\$(set +o); \$(shopt -p)"
source ${YP_DIR}/bootstrap/brew-util/env.inc.sh
source ${YP_DIR}/sh/dev.inc.sh
# revert any shell options set in the scripts above
eval "\${OPTS_STATE}"; unset OPTS_STATE
EOF
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.bash_aliases

mkdir -p /home/${UNAME}/.ssh
chmod 700 /home/${UNAME}/.ssh
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.ssh

ln -sf /yplatform/sshconfig /home/${UNAME}/.ssh/yplatform
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.ssh/yplatform

cat <<EOF > /home/${UNAME}/.ssh/config
Include ~/.ssh/yplatform/config
Include ~/.ssh/yplatform/config.github
EOF
chmod 600 /home/${UNAME}/.ssh/config
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.ssh/config

touch /home/${UNAME}/.sudo_as_admin_successful
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.sudo_as_admin_successful
