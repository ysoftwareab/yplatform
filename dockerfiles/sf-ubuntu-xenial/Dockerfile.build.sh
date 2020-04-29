#!/usr/bin/env bash
set -euo pipefail

function apt_update() {
    apt-get update -y --fix-missing 2>&1 || {
        # try to handle "Hash Sum mismatch" error
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        apt-get update -y --fix-missing
    }
}

function apt_install() {
    apt-get install -y --force-yes $*
}

export CI=true
export DEBIAN_FRONTEND=noninteractive
# export SF_DOCKER_CI_IMAGE_NAME= # --build-arg
# export SF_DOCKER_CI_IMAGE_TAG= # --build-arg
# export SF_CI_BREW_INSTALL= # --build-arg

# DEPS
apt_update
apt_install apt-transport-https
apt_install software-properties-common ca-certificates
apt_install git openssl ssh-client sudo

# SSH
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod 600 /root/.ssh/config

# GIT
git config --global user.email "${SF_DOCKER_CI_IMAGE_NAME}.${SF_DOCKER_CI_IMAGE_TAG}@docker"
git config --global user.name "${SF_DOCKER_CI_IMAGE_NAME} ${SF_DOCKER_CI_IMAGE_TAG}"

# GID UID
GID_INDEX=999
UID_INDEX=999
GNAME=sf
UNAME=sf

# NON-ROOT SUDO USER
GNAME=codeship
GID_INDEX=$((GID_INDEX + 1))
addgroup \
    --gid ${GID_INDEX} \
    ${GNAME}
UNAME=codeship
UID_INDEX=$((UID_INDEX + 1))
adduser \
    --uid ${UID_INDEX} \
    --ingroup ${UNAME} \
    --home /home/${UNAME} \
    --shell /bin/sh \
    --disabled-password \
    --gecos "" \
    ${UNAME}
adduser ${UNAME} sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# MAIN
{
    cd /support-firecloud
    chown -R root:root .
    git config url."https://github.com/".insteadOf git@github.com:

    # hack to optimize usage in travis and not do 'chown -R' (slow) after each 'docker run'
    # see https://github.com/docker/for-linux/issues/388
    # TODO see repo/dot.ci.sh.sf sf_run_docker
    usermod -u 2000 ${UNAME}
    groupmod -g 2000 ${GNAME}

    sudo --preserve-env -H -u ${UNAME} ./ci/linux/bootstrap

    # unhack
    # see https://github.com/docker/for-linux/issues/388
    # TODO see repo/dot.ci.sh.sf sf_run_docker
    usermod -u ${UID_INDEX} ${UNAME}
    groupmod -g ${GID_INDEX} ${GNAME}

    git rev-parse HEAD > /support-firecloud.bootstrapped

    # make 'docker run --rm -it --user sf <image>' behave like a dev machine
    cat <<EOF >> /home/sf/.bash_aliases
source ~/git/firecloud/support-firecloud/sh/dev.inc.sh

# unhack
# see https://github.com/docker/for-linux/issues/388
# TODO see repo/dot.ci.sh.sf sf_run_docker
[[ $(find /home/linuxbrew -maxdepth 0 -printf '%u\n') = $(id -u) ]] || \
    chown -R $(id -u):$(id -g) /home/linuxbrew
EOF
    chown ${UNAME}:${GNAME} /home/${UNAME}/.bash_aliases

    cat <<EOF >> /home/${UNAME}/.gitconfig
[include]
    path = /support-firecloud/generic/dot.gitconfig
EOF
}

# CLEANUP
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

apt-get clean
dir_clean /var/lib/apt/lists/* # aptitude cache
dir_clean /home/sf/.cache # linuxbrew cache

git_dir_clean /support-firecloud
# git_dir_clean /home/linuxbrew/.linuxbrew/Homebrew
# git_dir_clean /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core
