#!/usr/bin/env bash
set -euo pipefail

function dir_clean() {
    du -hcs $1
    rm -rf $1
}

function git_dir_clean() {
    du -hcs $1
    (
        cd $1
        git clean -xdf .
        git submodule foreach --recursive git clean -xdf .
        git reset --hard HEAD
        git submodule foreach --recursive git reset --hard HEAD
        git reflog expire --expire=now --all
        git gc --aggressive --prune=now
    )
    ${SUPPORT_FIRECLOUD_DIR}/bin/git-shallow $1
    du -hcs $1
}

(
    cd ${SUPPORT_FIRECLOUD_DIR}
    git add -f -- BUILD VERSION
    git_dir_clean ${SUPPORT_FIRECLOUD_DIR}
    git reset -- BUILD VERSION
)

apt-get clean || true # aptitude cache
dir_clean /var/lib/apt/lists/* || true # aptitude cache
dir_clean /var/cache/apk/* || true # apk cache
dir_clean /home/${UNAME}/.cache/* || true # linuxbrew cache

git_dir_clean /home/linuxbrew/.linuxbrew/Homebrew
chown -R ${UNAME}:${GNAME} /home/linuxbrew/.linuxbrew/Homebrew
for BREW_TAP in /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*/*; do
    git_dir_clean ${BREW_TAP}
    chown -R ${UNAME}:${GNAME} ${BREW_TAP}
done
