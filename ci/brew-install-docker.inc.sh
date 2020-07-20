#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Docker packages..."

BREW_FORMULAE="$(cat <<-EOF
docker
docker-compose
EOF
)"

case ${OS} in
    linux)
        brew_install "${BREW_FORMULAE}"
        ;;
    darwin)
        which docker >/dev/null 2>&1 || brew cask install docker
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
