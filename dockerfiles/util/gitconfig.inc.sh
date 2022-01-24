#!/usr/bin/env bash
set -euo pipefail

# NOTE sync with ci/util/gitconfig.inc.sh

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${UHOME}/.gitignore_global ."
[[ ! -e "${UHOME}/.gitignore_global" ]] || \
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Overwriting ${UHOME}/.gitignore_global ."
ln -sf ${YP_DIR}/gitconfig/dot.gitignore_global ${UHOME}/.gitignore_global
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.gitignore_global

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${UHOME}/.gitattributes_global ."
[[ ! -e "${UHOME}/.gitattributes_global" ]] || \
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Overwriting ${UHOME}/.gitattributes_global ."
ln -sf ${YP_DIR}/gitconfig/dot.gitattributes_global ${UHOME}/.gitattributes_global
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.gitattributes_global

>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${UHOME}/.gitconfig ."
# NOTE we want to prepend, and let the original .gitconfig override YP configuration
# git config --global --add include.path ${YP_DIR}/gitconfig/dot.gitconfig
touch ${UHOME}/.gitconfig
git config --file ${UHOME}/.gitconfig --get-all "include.path" | grep -q -Fx "${YP_DIR}/gitconfig/dot.gitconfig" || \
    printf '%s\n%s\n%s\n' \
        "[include]" \
        "path = ${YP_DIR}/gitconfig/dot.gitconfig" \
        "$(cat ${UHOME}/.gitconfig)" >${UHOME}/.gitconfig
>&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup git user '${GIT_USER_NAME:-}' and email '${GIT_USER_EMAIL:-}'."
[[ -z "${GIT_USER_NAME:-}" ]] || git config --global user.name "${GIT_USER_NAME}"
[[ -z "${GIT_USER_EMAIL:-}" ]] || git config --global user.email "${GIT_USER_EMAIL}"
chown ${UID_INDEX}:${GID_INDEX} ${UHOME}/.gitconfig
