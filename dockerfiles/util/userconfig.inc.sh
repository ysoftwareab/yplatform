#!/usr/bin/env bash
set -euo pipefail

PROFILE_FILE=
if [[ -e ${UHOME}/.bash_profile ]]; then
    PROFILE_FILE=${UHOME}/.bash_profile
elif [[ -e ${UHOME}/.profile ]]; then
    PROFILE_FILE=${UHOME}/.profile
elif [[ -e /etc/skel/.bash_profile ]]; then
    PROFILE_FILE=${UHOME}/.bash_profile
elif [[ -e /etc/skel/.profile ]]; then
    PROFILE_FILE=${UHOME}/.profile
else
    PROFILE_FILE=${UHOME}/.bash_profile
fi
touch ${PROFILE_FILE}
cat ${PROFILE_FILE} | grep -q "/\.bashrc" || cat <<EOF >> ${PROFILE_FILE}
[[ -z "${BASH:-}" ]] || [[ ! -f ~/.bashrc ]] || . ~/.bashrc
EOF
cat ${PROFILE_FILE} | grep -q "/\.bashrc"
chown ${UID_INDEX}:${GID_INDEX} ${PROFILE_FILE}

[[ -e ${UHOME}/.bashrc ]] || cat <<EOF >> ${UHOME}/.bashrc
# If not running interactively, don't do anything
[[ $- = *i* ]] || return
EOF
cat ${UHOME}/.bashrc | grep -q "/\.bash_aliases" || cat <<EOF >> ${UHOME}/.bashrc
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[[ ! -f ~/.bash_aliases ]] || . ~/.bash_aliases
EOF
cat ${UHOME}/.bashrc | grep -q "/\.bash_aliases"
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
