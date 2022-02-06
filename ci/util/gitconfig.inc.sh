#!/usr/bin/env bash
set -euo pipefail

# NOTE sync with dockerfiles/util/gitconfig.inc.sh

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitignore_global ."
[[ ! -e "${HOME}/.gitignore_global" ]] || \
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Overwriting ${HOME}/.gitignore_global ."
ln -sfn ${YP_DIR}/gitconfig/dot.gitignore_global ${HOME}/.gitignore_global

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitattributes_global ."
[[ ! -e "${HOME}/.gitattributes_global" ]] || \
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Overwriting ${HOME}/.gitattributes_global ."
ln -sfn ${YP_DIR}/gitconfig/dot.gitattributes_global ${HOME}/.gitattributes_global

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitconfig ."
# NOTE we want to prepend, and let the original .gitconfig override YP configuration
# git config --global --add include.path ${YP_DIR}/gitconfig/dot.gitconfig
touch ${HOME}/.gitconfig
git config -f ${HOME}/.gitconfig --get-all "include.path" | grep -q -Fx "${YP_DIR}/gitconfig/dot.gitconfig" || \
    printf '%s\n%s\n%s\n' \
        "[include]" \
        "path = ${YP_DIR}/gitconfig/dot.gitconfig" \
        "$(cat ${HOME}/.gitconfig)" >${HOME}/.gitconfig
>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup git user '${GIT_USER_NAME:-}' and email '${GIT_USER_EMAIL:-}'."
[[ -z "${GIT_USER_NAME:-}" ]] || git config -f ${HOME}/.gitconfig user.name "${GIT_USER_NAME}"
[[ -z "${GIT_USER_EMAIL:-}" ]] || git config -f ${HOME}/.gitconfig user.email "${GIT_USER_EMAIL}"
