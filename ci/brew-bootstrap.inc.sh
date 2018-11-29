#!/usr/bin/env bash
set -euo pipefail

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

case $(uname -s) in
    Darwin)
        echo_do "brew: Installing homebrew..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || \
            true # fails if already installed
        echo_done

        TRAVIS_CACHE_HOMEBREW_PREFIX=~/.homebrew
        HOMEBREW_PREFIX=/usr/local
        ;;
    Linux)
        echo_do "brew: Installing linuxbrew..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
        echo_done

        TRAVIS_CACHE_HOMEBREW_PREFIX=~/.linuxbrew
        if [[ -x ~/.linuxbrew/bin/brew ]]; then
            HOMEBREW_PREFIX=~/.linuxbrew
        elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
        fi
        ;;
    *)
        echo_err "brew: $(uname -s) is an unsupported OS."
        return 1
        ;;
esac

[[ -n "${HOMEBREW_PREFIX:-}" ]] || {
    echo_err "brew: HOMEBREW_PREFIX is undefined."
    return 1
}

if [[ "$(cd ${HOMEBREW_PREFIX} && pwd)" != "$(cd ${TRAVIS_CACHE_HOMEBREW_PREFIX} && pwd)" ]]; then
    echo_do "brew: Restoring cache..."
    if [[ -d "${TRAVIS_CACHE_HOMEBREW_PREFIX}/Homebrew" ]]; then
        echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Homebrew..."
        rsync -a --inplace --delete ${TRAVIS_CACHE_HOMEBREW_PREFIX}/Homebrew ${HOMEBREW_PREFIX}/Homebrew
        echo_done
    fi
    # restore non-bottled formulae
    if [[ -d "${TRAVIS_CACHE_HOMEBREW_PREFIX}/Cellar" ]]; then
        for f in $(find ${TRAVIS_CACHE_HOMEBREW_PREFIX}/Cellar -mindepth 2 -maxdepth 2 -print); do
            f="$(basename $(dirname "${f}"))/$(basename "${f}")" # name/version
            [[ -f ${TRAVIS_CACHE_HOMEBREW_PREFIX}/Cellar/${f}/INSTALL_RECEIPT.json ]] || continue
            echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Cellar/${f}..."
            mkdir -p ${HOMEBREW_PREFIX}/Cellar/${f}
            rsync -a --inplace --delete ${TRAVIS_CACHE_HOMEBREW_PREFIX}/Cellar/${f}/ ${HOMEBREW_PREFIX}/Cellar/${f}/
            echo_done
        done
    fi
    echo_done
fi
unset TRAVIS_CACHE_HOMEBREW_PREFIX

export PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}
unset HOMEBREW_PREFIX

echo_do "brew: Upgrading..."
brew update
brew outdated
# trying to upgrade twice in case of intermediate complaints
brew upgrade || brew upgrade
echo_done

echo_do "brew: Installing/Upgrading git..."
brew list git >/dev/null 2>&1 || brew install git
brew outdated git >/dev/null 2>&1 || brew upgrade git
echo_done

brew_install() {
    echo "$@" | while read FORMULA; do
        local NAME=$(echo "${FORMULA}" | cut -d " " -f 1)
        local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)
        # is it already installed ?
        if brew list "${NAME}" >/dev/null 2>&1; then
            # do we require installation with specific options ?
            [[ -n "${OPTIONS}" ]] || continue

            # is it already installed with the required options ?
            local USED_OPTIONS="$(brew info --json=v1 ${NAME} | \
                /usr/bin/python \
                    -c 'import sys,json;print "".join(json.load(sys.stdin)[0]["installed"][0]["used_options"])' | \
                xargs -n1 | \
                sort -u || true)"
            local NOT_FOUND_OPTIONS="$(comm -23 <(echo "${OPTIONS}") <(echo "${USED_OPTIONS}"))"
            [[ -n "${NOT_FOUND_OPTIONS}" ]] || continue

            echo_err "${NAME} is already installed with options '${USED_OPTIONS}',"
            echo_err "but not the required '${NOT_FOUND_OPTIONS}'."

            if [[ "${TRAVIS:-}" = "true" ]]; then
                brew uninstall ${FORMULA}
            else
                echo_err "Consider uninstalling ${NAME} with 'brew uninstall ${NAME}' and rerun the bootstrap!"
                return 1
            fi
        fi
        echo_do "brew: Installing ${FORMULA}..."
        brew install ${FORMULA}
        echo_done
    done
}

brew_list() {
    echo_do "brew: Listing packages..."
    brew list --versions
    echo_done
}

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/bin/common.inc.sh
