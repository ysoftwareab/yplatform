#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Docker packages..."

# shellcheck disable=SC1091
case ${OS_SHORT}-$(source /etc/os-release && echo ${ID} || echo true) in
    darwin-*|linux-alpine)
        brew_install_one_if docker "docker --version | head -1" "^Docker version \(19\|20\)\."
        brew_install_one_if docker-compose "docker-compose --version | head -1" "^docker-compose version 1\."
        ;;
    # linux-alpine)
    #     # https://wiki.alpinelinux.org/wiki/Docker#Installation
    #     apk_install_one docker
    #     apk_install_one docker-compose
    #     addgroup $(whoami) docker
    #     rc-update add docker boot
    #     service docker start
    #     ;;
    linux-debian|linux-ubuntu)
        # docker-compose via linuxbrew will throw 'Illegal instruction' for e.g. 'docker-compose --version'
        # brew_install_one docker
        # brew_install_one docker-compose

        # shellcheck disable=SC1091
        RELEASE_ID="$(source /etc/os-release && echo ${ID})"
        # shellcheck disable=SC1091
        # RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"

        # BEGIN https://docs.docker.com/engine/install/ubuntu/
        for PKG in docker docker-engine docker.io containerd runc; do
            ${SF_SUDO} apt-get remove ${PKG} || true;
        done
        unset PKG

        apt_install_one apt-transport-https
        apt_install_one ca-certificates
        apt_install_one curl
        apt_install_one gnupg-agent
        apt_install_one software-properties-common

        curl -fqsSL https://download.docker.com/linux/${RELEASE_ID}/gpg | ${SF_SUDO} apt-key add -
        ${SF_SUDO} apt-key fingerprint 0EBFCD88
        ${SF_SUDO} add-apt-repository -u \
            "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/${RELEASE_ID} $(lsb_release -cs) stable"

        apt_install_one docker-ce
        apt_install_one docker-ce-cli
        apt_install_one containerd.io
        # ENV https://docs.docker.com/engine/install/ubuntu/

        # BEGIN https://docs.docker.com/compose/install/
        DOCKER_COMPOSE_LATEST_URL=https://github.com/docker/compose/releases/latest/download
        ${SF_SUDO} curl -fqsSL -o /usr/local/bin/docker-compose \
            "${DOCKER_COMPOSE_LATEST_URL}/docker-compose-$(uname -s)-$(uname -m)"
        ${SF_SUDO} chmod +x /usr/local/bin/docker-compose
        unset DOCKER_COMPOSE_LATEST_URL
        # END https://docs.docker.com/compose/install/

        unset RELEASE_ID
        unset RELEASE_VERSION_ID

        exe_and_grep_q "docker --version | head -1" "^Docker version \(19\|20\)\."
        exe_and_grep_q "docker-compose --version | head -1" "^docker-compose version 1\."
        ;;
    *)
        # shellcheck disable=SC1091
        echo_err "${OS_SHORT}-$(source /etc/os-release && echo ${ID} || echo true) is an unsupported OS for installing Docker."
        return 1
        ;;
esac

echo_done
