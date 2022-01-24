#!/usr/bin/env bash
# -*- mode: sh -*-
set -euo pipefail

YP_DIR=/yplatform
source ${YP_DIR}/dockerfiles/util/common.inc.sh

[[ $# -gt 0 ]] || {
    # shellcheck disable=SC1091
    UNAME=$(source ${YP_DIR}/dockerfiles/util/env.inc.sh && echo "${UNAME}")
    BASH=$(command -v bash)

    echo_do "Test root user config..."
    sudo --preserve-env --set-home --user root ${BASH} -l -i -c "${BASH_SOURCE[0]} root"
    echo_done

    echo_do "Test ${UNAME} user config..."
    sudo --preserve-env --set-home --user ${UNAME} ${BASH} -l -i -c "${BASH_SOURCE[0]} ${UNAME}"
    echo_done

    exit 0
}

# BASH

echo_do "Test bash env..."
XTRACE_STATE_DOCKERFILE_TEST_SH="$(set +o | grep xtrace)"
set -x

ls -la ${HOME}/.bash_aliases
cat ${HOME}/.bash_aliases | grep -q -Fx "source ${YP_DIR}/bootstrap/brew-util/env.inc.sh"
cat ${HOME}/.bash_aliases | grep -q -Fx "source ${YP_DIR}/sh/dev.inc.sh"

# shellcheck disable=SC2016
env -i HOME=${HOME} bash -l -i -c '[[ "${YP_DEV_INC_SH}" = true ]]'
env -i HOME=${HOME} bash -l -i -c 'command -v brew'

eval "${XTRACE_STATE_DOCKERFILE_TEST_SH}"
unset XTRACE_STATE_DOCKERFILE_TEST_SH
echo_done

# GIT

echo_do "Test git config..."
XTRACE_STATE_DOCKERFILE_TEST_SH="$(set +o | grep xtrace)"
set -x

ls -la ${HOME}/.gitattributes_global
[[ "$(readlink -f ${HOME}/.gitattributes_global)" = "${YP_DIR}/gitconfig/dot.gitattributes_global" ]]

ls -la ${HOME}/.gitignore_global
[[ "$(readlink -f ${HOME}/.gitignore_global)" = "${YP_DIR}/gitconfig/dot.gitignore_global" ]]

ls -la ${HOME}/.gitconfig
git config -f ${HOME}/.gitconfig --get "user.name" || true
git config -f ${HOME}/.gitconfig --get "user.name" | ${YP_DIR}/bin/ifne -f -p
git config -f ${HOME}/.gitconfig --get "user.email" || true
git config -f ${HOME}/.gitconfig --get "user.email" | ${YP_DIR}/bin/ifne -f -p
git config -f ${HOME}/.gitconfig --get-all "include.path" || true
git config -f ${HOME}/.gitconfig --get-all "include.path" | grep -q -Fx "${YP_DIR}/gitconfig/dot.gitconfig"

eval "${XTRACE_STATE_DOCKERFILE_TEST_SH}"
unset XTRACE_STATE_DOCKERFILE_TEST_SH
echo_done

# SSH

echo_do "Test ssh config..."
XTRACE_STATE_DOCKERFILE_TEST_SH="$(set +o | grep xtrace)"
set -x

ls -la ${HOME}/.ssh/config
cat ${HOME}/.ssh/config | grep -q -Fx "Include ~/.ssh/yplatform/config"

ls -la ${HOME}/.ssh/yplatform
[[ "$(readlink -f ${HOME}/.ssh/yplatform)" = "${YP_DIR}/sshconfig" ]]

eval "${XTRACE_STATE_DOCKERFILE_TEST_SH}"
unset XTRACE_STATE_DOCKERFILE_TEST_SH
echo_done

# MISC

echo_do "Test misc config..."
XTRACE_STATE_DOCKERFILE_TEST_SH="$(set +o | grep xtrace)"
set -x

[[ "${USER}" = "root" ]] || test -f ${HOME}/.sudo_as_admin_successful

eval "${XTRACE_STATE_DOCKERFILE_TEST_SH}"
unset XTRACE_STATE_DOCKERFILE_TEST_SH
echo_done
