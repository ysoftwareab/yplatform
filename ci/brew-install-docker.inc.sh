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
            ;;
        Linux)
            (
                RELEASE_ID="$(source /etc/os-release && echo ${ID})"
                RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"
                RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
                case ${RELEASE_ID}-${RELEASE_VERSION_CODENAME} in
                    ubuntu-focal)
                        # docker-compose via linuxbrew fails on Ubuntu 20.04
                        apt_install docker
                        apt_install docker-compose
                        ;;
                    *)
                        brew_install docker
                        brew_install docker-compose
                        ;;
                esac
            )
            ;;
        *)
            echo_err "${OS} is an unsupported OS for installing Docker."
            return 1
            ;;
    esac

    echo_done

    echo_do "brew: Testing Docker packages..."
    exe_and_grep_q "docker --version | head -1" "^Docker version 19\."
    exe_and_grep_q "docker-compose --version | head -1" "^docker-compose version 1\."
    echo_done
fi
