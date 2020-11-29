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
    apt-get install -y ${FORCE_YES} "$@"
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
echo -e "Host github.com\n  StrictHostKeyChecking yes\n  CheckHostIP no" >/root/.ssh/config
chmod 600 /root/.ssh/config
echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >/root/.ssh/known_hosts
chmod 600 /root/.ssh/known_hosts

# GIT
git config --global user.email "bot@codeship.com"
git config --global user.name "Codeship"

# GID UID
GID_INDEX=999
UID_INDEX=999
GNAME=codeship
UNAME=codeship

# NON-ROOT SUDO USER
GID_INDEX=$((GID_INDEX + 1))
cat /etc/group | cut -d":" -f3 | grep -q "^${GID_INDEX}$" || addgroup \
    --gid ${GID_INDEX} \
    ${GNAME}
GNAME_REAL=$(getent group ${GID_INDEX} | cut -d: -f1)

UID_INDEX=$((UID_INDEX + 1))
adduser \
    --uid ${UID_INDEX} \
    --ingroup ${GNAME_REAL} \
    --home /home/${UNAME} \
    --shell /bin/sh \
    --disabled-password \
    --gecos "" \
    ${UNAME}
adduser ${UNAME} sudo
echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "Defaults:${UNAME} !env_reset" >> /etc/sudoers
echo "Defaults:${UNAME} !secure_path" >> /etc/sudoers
cp -RP /root/.ssh /home/${UNAME}/
chown -R ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.ssh
