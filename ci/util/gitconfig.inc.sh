#!/usr/bin/env bash
set -euo pipefail

# NOTE sync with dockerfiles/util/gitconfig.inc.sh
if command -v git >/dev/null 2>&1; then
    >&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitconfig ."
    # NOTE we want to prepend, and let the original .gitconfig override YP configuration
    # git config --global --add include.path ${YP_DIR}/gitconfig/dot.gitconfig
    touch ~/.gitconfig
    printf '[include]\npath = '"${YP_DIR}"'/gitconfig/dot.gitconfig\n%s\n' "$(cat ~/.gitconfig)" >~/.gitconfig

    >&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitignore_global ."
    ln -sf ${YP_DIR}/gitconfig/dot.gitignore_global ~/.gitignore_global

    >&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup ${HOME}/.gitattributes_global ."
    ln -sf ${YP_DIR}/gitconfig/dot.gitattributes_global ~/.gitattributes_global

    >&2 echo "$(date +"%H:%M:%S")" "[INFO] Setup git user."
    [[ -z "${YP_CI_PLATFORM:-}" ]] || [[ -z "${YP_CI_SERVER_HOST:-}" ]] || \
        git config --global user.email "${YP_CI_PLATFORM}@${YP_CI_SERVER_HOST}"
    [[ -z "${YP_CI_NAME:-}" ]] || \
        git config --global user.name "${YP_CI_NAME}"
fi
