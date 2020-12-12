#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing Docker packages..."
else
    echo_do "brew: Installing Docker packages..."

    case $(uname -s) in
        Darwin)
            HAS_DOCKER=true
            if which docker >/dev/null 2>&1; then
                exe_and_grep_q "docker --version | head -1" "^Docker version." || HAS_DOCKER=false
            else
                HAS_DOCKER=false
            fi
            if ${HAS_DOCKER}; then
                echo_skip "Installing Docker via 'brew cask'."
            else
                if [[ "${CI:-}" = "true" ]]; then
                    echo_skip "Installing Docker via 'brew cask'..."
                    echo_do "Installing Docker via 'brew'..."
                    brew_install docker
                    brew_install docker-compose
                    echo_done
                else
                    echo_do "Installing Docker via 'brew cask'..."
                    brew cask install docker
                    echo_done
                fi
            fi
            unset HAS_DOCKER
            ;;
        Linux)
            # docker-compose via linuxbrew will throw 'Illegal instruction' for e.g. 'docker-compose --version'
            # brew_install docker
            # brew_install docker-compose

            # shellcheck disable=SC1091
            RELEASE_ID="$(source /etc/os-release && echo ${ID})"
            # shellcheck disable=SC1091
            # RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"
            # shellcheck disable=SC1091
            # RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"

            # BEGIN https://docs.docker.com/engine/install/ubuntu/
            for PKG in docker docker-engine docker.io containerd runc; do
                ${SF_SUDO} apt-get remove ${PKG} || true;
            done
            unset PKG

            apt_install apt-transport-https
            apt_install ca-certificates
            apt_install curl
            apt_install gnupg-agent
            apt_install software-properties-common

            curl -fqsSL https://download.docker.com/linux/${RELEASE_ID}/gpg | ${SF_SUDO} apt-key add -
            ${SF_SUDO} apt-key fingerprint 0EBFCD88
            ${SF_SUDO} add-apt-repository -u \
                "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/${RELEASE_ID} $(lsb_release -cs) stable"

            apt_install docker-ce
            apt_install docker-ce-cli
            apt_install containerd.io
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
            unset RELEASE_VERSION_CODENAME
            ;;
        *)
            echo_err "$(uname -s) is an unsupported OS for installing Docker."
            return 1
            ;;
    esac

    echo_done

    echo_do "brew: Testing Docker packages..."
    exe_and_grep_q "docker --version | head -1" "^Docker version \(19\|20\)\."
    exe_and_grep_q "docker-compose --version | head -1" "^docker-compose version 1\."
    echo_done
fi
