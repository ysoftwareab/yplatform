#!/usr/bin/env bash
set -euo pipefail

function dir_clean() {
    echo_do "${FUNCNAME[0]}: $1..."
    set -x
    du -hcs $1
    rm -rf $1
    set +x
    echo_done
}

function git_dir_clean() {
    echo_do "${FUNCNAME[0]}: $1..."
    set -x
    du -hcs $1
    cd $1
    git clean -xdf .
    git submodule foreach --recursive git clean -xdf .
    git reset --hard HEAD
    git submodule foreach --recursive git reset --hard HEAD
    git reflog expire --expire=now --all
    git gc --prune=now
    cd -
    ${SUPPORT_FIRECLOUD_DIR}/bin/git-shallow $1
    du -hcs $1
    set +x
    echo_done
}

(
    cd ${SUPPORT_FIRECLOUD_DIR}
    git add -f -- BUILD VERSION
    git_dir_clean ${SUPPORT_FIRECLOUD_DIR}
    git reset -- BUILD VERSION
)

brew_cache_prune
magic_cache_prune

for DIR in /home/linuxbrew/.linuxbrew/Homebrew /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*/*; do
    git_dir_clean ${DIR}
    chown -R ${UNAME}:${GNAME} ${DIR}
done
