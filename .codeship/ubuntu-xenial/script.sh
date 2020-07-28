#!/usr/bin/env bash
set -euo pipefail

function apt_update() {
    apt-get update -y --fix-missing 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        apt-get update -o Acquire::CompressionTypes::Order::=gz
        apt-get update -y --fix-missing
        set +x
    }
}

function apt_install() {
    local FORCE_YES="--allow-downgrades --allow-remove-essential --allow-change-held-packages"
    # apt-get install -y --force-yes $*
    apt-get install -y ${FORCE_YES} $*
}

export DEBIAN_FRONTEND=noninteractive

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
git config --global user.email "bot@codeship.com"
git config --global user.name "Codeship"

# GID UID
GID_INDEX=999
UID_INDEX=999

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
echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
