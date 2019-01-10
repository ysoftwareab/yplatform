#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

case $(uname -s) in
    Darwin)
        echo_do "brew: Installing homebrew..."
        </dev/null ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo_done

        CI_CACHE_HOMEBREW_PREFIX=~/.homebrew
        ;;
    Linux)
        echo_do "brew: Installing linuxbrew..."
        </dev/null sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
        echo_done

        CI_CACHE_HOMEBREW_PREFIX=~/.linuxbrew
        ;;
    *)
        echo_err "brew: $(uname -s) is an unsupported OS."
        return 1
        ;;
esac

source ${SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh

HOMEBREW_PREFIX=$(brew --prefix)
[[ "${CI}" != "true" ]] || [[ "$(cd ${HOMEBREW_PREFIX} && pwd)" = "$(cd ${CI_CACHE_HOMEBREW_PREFIX} && pwd)" ]] || {
    echo_do "brew: Restoring cache..."
    if [[ -d "${CI_CACHE_HOMEBREW_PREFIX}/Homebrew" ]]; then
        echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Homebrew..."
        RSYNC_CMD="rsync -a --delete ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew/ ${HOMEBREW_PREFIX}/Homebrew/"
        ${RSYNC_CMD} || {
            exe ls -la ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew || true
            exe ls -la ${HOMEBREW_PREFIX}/Homebrew || true
            ${RSYNC_CMD} --verbose
        }
        unset RSYNC_CMD
        echo_done
    fi

    # restore non-bottled formulae
    if [[ -d "${CI_CACHE_HOMEBREW_PREFIX}/Cellar" ]]; then
        for f in $(find ${CI_CACHE_HOMEBREW_PREFIX}/Cellar -mindepth 2 -maxdepth 2 -print); do
            f="$(basename $(dirname "${f}"))/$(basename "${f}")" # name/version
            [[ -f ${CI_CACHE_HOMEBREW_PREFIX}/Cellar/${f}/INSTALL_RECEIPT.json ]] || continue
            echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Cellar/${f}..."
            mkdir -p ${HOMEBREW_PREFIX}/Cellar/${f}
            RSYNC_CMD="rsync -a --delete ${CI_CACHE_HOMEBREW_PREFIX}/Cellar/${f}/ ${HOMEBREW_PREFIX}/Cellar/${f}/"
            ${RSYNC_CMD} || {
                exe ls -la ${CI_CACHE_HOMEBREW_PREFIX}/Cellar/${f}/ || true
                exe ls -la ${HOMEBREW_PREFIX}/Cellar/${f}/ || true
                ${RSYNC_CMD} --verbose
            }
            unset RSYNC_CMD
            echo_done
        done
    fi
    echo_done
}
unset HOMEBREW_PREFIX
unset CI_CACHE_HOMEBREW_PREFIX

echo_do "brew: Updating..."
brew update
brew outdated
echo_done

echo_do "brew: Installing/Upgrading git..."
brew list git >/dev/null 2>&1 || brew install git
brew outdated git >/dev/null 2>&1 || brew upgrade git
echo_done

brew_upgrade() {
    echo "$@" | while read NAME; do
        # is it pinned?
        brew list ${NAME} --pinned | grep -q "^${NAME}$" || {
            # is it already up-to-date?
            brew outdated ${NAME} >/dev/null 2>&1 || {
                echo_do "brew: Upgrading ${NAME}..."
                brew upgrade ${NAME}
                echo_done
            }
        }
    done
}

brew_install() {
    echo "$@" | while read FORMULA; do
        local NAME=$(echo "${FORMULA}" | cut -d " " -f 1)
        local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)
        # is it already installed ?
        if brew list "${NAME}" >/dev/null 2>&1; then
            # do we require installation with specific options ?
            [[ -n "${OPTIONS}" ]] || {
                echo_skip "brew: Installing ${FORMULA}..."
                brew link ${NAME} || true
                brew_upgrade ${NAME}
                continue
            }

            # is it already installed with the required options ?
            local USED_OPTIONS="$(brew info --json=v1 ${NAME} | \
                /usr/bin/python \
                    -c 'import sys,json;print "".join(json.load(sys.stdin)[0]["installed"][0]["used_options"])' | \
                xargs -n1 | \
                sort -u || true)"
            local NOT_FOUND_OPTIONS="$(comm -23 <(echo "${OPTIONS}") <(echo "${USED_OPTIONS}"))"
            [[ -n "${NOT_FOUND_OPTIONS}" ]] || {
                echo_skip "brew: Installing ${FORMULA}..."
                brew link ${NAME} || true
                brew_upgrade ${NAME}
                continue
            }

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

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
