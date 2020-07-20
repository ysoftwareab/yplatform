#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing Docker packages..."
else
    echo_do "brew: Installing Docker packages..."

    BREW_FORMULAE="$(cat <<-EOF
docker
docker-compose
EOF
)"

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
                echo_do "Installing Docker via 'brew cask'..."
                brew cask install docker
                echo_done
            fi
            ;;
        Linux)
            brew_install "${BREW_FORMULAE}"
            ;;
        *)
            echo_err "${OS} is an unsupported OS for installing Docker."
            return 1
            ;;
    esac
    unset BREW_FORMULAE

    echo_done

    echo_do "brew: Testing Docker packages..."
    exe_and_grep_q "docker --version | head -1" "^Docker version 19\."
    exe_and_grep_q "docker-compose --version | head -1" "^docker-compose version 1\."
    echo_done
fi
