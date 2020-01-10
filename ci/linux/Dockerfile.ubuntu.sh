#!/usr/bin/env bash
set -euo pipefail

apt-get-install() {
    apt-get install -y --no-install-recommends $*
}

export CI=true
export DEBIAN_FRONTEND=noninteractive
# export IMAGE_TAG= # --build-arg
# export SF_CI_BREW_INSTALL= # --build-arg

# DEPS
apt-get update -y --fix-missing
apt-get-install apt-transport-https
apt-get-install software-properties-common ca-certificates
apt-get-install git openssl ssh-client sudo
rm -rf /var/lib/apt/lists/*

# SSH
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod 600 /root/.ssh/config

# GIT
git config --global user.email "${IMAGE_TAG}@docker"
git config --global user.name "${IMAGE_TAG}"

# NON-ROOT SUDO USER
addgroup \
    --gid 1000 \
    sf
adduser \
    --uid 1000 \
    --ingroup sf \
    --home /home/sf \
    --shell /bin/sh \
    --disabled-password \
    --gecos "" \
    sf
adduser sf sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# MAIN
{
    cd /support-firecloud
    chown -R root:root .
    git config url."https://github.com/".insteadOf git@github.com:
    sudo --preserve-env -H -u sf ./ci/linux/bootstrap
    touch /support-firecloud.bootstrapped
}
