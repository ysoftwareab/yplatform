#!/usr/bin/env bash
set -euo pipefail

# NOTE sync with ci/util/gitconfig.inc.sh

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitconfig ."
# NOTE we want to prepend, and let the original .gitconfig override YP configuration
# git config --global --add include.path ${YP_DIR}/gitconfig/dot.gitconfig
touch ${HOME}/.gitconfig
cat ${HOME}/.gitconfig | grep -q "${YP_DIR}/gitconfig/dot.gitconfig" || \
    printf '%s\n%s\n' \
        "$(echo -e "[include]\npath = ${YP_DIR}/gitconfig/dot.gitconfig")" \
        "$(cat ~/.gitconfig)" >~/.gitconfig

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitignore_global ."
ln -sf ${YP_DIR}/gitconfig/dot.gitignore_global ~/.gitignore_global

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitattributes_global ."
ln -sf ${YP_DIR}/gitconfig/dot.gitattributes_global ~/.gitattributes_global

git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"
