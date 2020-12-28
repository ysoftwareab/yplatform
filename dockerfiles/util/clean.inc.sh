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
        git reflog expire --expire=all --all
        git tag -l | xargs -r git tag -d
        git gc --prune=all
        git clean -xdf .
    )
    du -hcs $1
}

(
    cd ${SUPPORT_FIRECLOUD_DIR}
    git add -f -- BUILD VERSION
    git_dir_clean ${SUPPORT_FIRECLOUD_DIR}
    git reset -- BUILD VERSION
)

apt-get clean
dir_clean /var/lib/apt/lists/* # aptitude cache
dir_clean /home/${UNAME}/.cache/* # linuxbrew cache

git_dir_clean /home/linuxbrew/.linuxbrew/Homebrew
chown -R ${UNAME}:${GNAME} /home/linuxbrew/.linuxbrew/Homebrew
for BREW_TAP in /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*/*; do
    git_dir_clean ${BREW_TAP}
    chown -R ${UNAME}:${GNAME} ${BREW_TAP}
done
