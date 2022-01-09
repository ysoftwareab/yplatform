#!/usr/bin/env bash
set -euo pipefail

YP_DIR=/yplatform

[[ $# -gt 0 ]] || {
    # shellcheck disable=SC1091
    UNAME=$(source ${YP_DIR}/dockerfiles/util/env.inc.sh && echo "${UNAME}")
    BASH=$(command -v bash)

    sudo ${BASH} -l -i -c "${BASH_SOURCE[0]} root"
    sudo --user ${UNAME} ${BASH} -l -i -c "${BASH_SOURCE[0]} ${UNAME}"
    exit 0
}

set -x

# BASH

test -f ${HOME}/.bash_aliases
cat ${HOME}/.bash_aliases | grep -q -Fx "source ${YP_DIR}/bootstrap/brew-util/env.inc.sh"
cat ${HOME}/.bash_aliases | grep -q -Fx "source ${YP_DIR}/sh/dev.inc.sh"
# shellcheck disable=SC2016
env -i HOME=${HOME} bash -l -i -c '[[ "${YP_DEV_INC_SH}" = true ]]'
env -i HOME=${HOME} bash -l -i -c 'command -v brew'

# GIT

test -f ${HOME}/.gitattributes_global
[[ "$(readlink -f ${HOME}/.gitattributes_global)" = "${YP_DIR}/gitconfig/dot.gitattributes_global" ]]

test -f ${HOME}/.gitignore_global
[[ "$(readlink -f ${HOME}/.gitignore_global)" = "${YP_DIR}/gitconfig/dot.gitignore_global" ]]

test -f ${HOME}/.gitconfig
git config -f ${HOME}/.gitconfig --get user.name | ${YP_DIR}/bin/ifne -f -p
git config -f ${HOME}/.gitconfig --get user.email | ${YP_DIR}/bin/ifne -f -p
git config -f ${HOME}/.gitconfig --get-all include.path | grep -q -Fx "${YP_DIR}/gitconfig/dot.gitignore"

# SSH

test -f ${HOME}/.ssh/config
cat ${HOME}/.ssh/config | grep -q -Fx "Include ~/.ssh/yplatform/config"

test -f ${HOME}/.ssh/yplatform
[[ "$(readlink -f ${HOME}/.ssh/yplatform)" = "${YP_DIR}/sshconfig" ]]

# MISC

[[ "${USER}" = "root" ]] || test -f ${HOME}/.sudo_as_admin_successful
