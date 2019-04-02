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
HOMEBREW_PREFIX_FULL=$(cd ${HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
CI_CACHE_HOMEBREW_PREFIX_FULL=$(cd ${CI_CACHE_HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
[[ "${CI}" != "true" ]] || [[ "${HOMEBREW_PREFIX_FULL}" = "${CI_CACHE_HOMEBREW_PREFIX_FULL}" ]] || {
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
    echo_done
}
unset HOMEBREW_PREFIX
unset CI_CACHE_HOMEBREW_PREFIX

echo_do "brew: Updating..."
brew update
brew outdated
echo_done

brew_upgrade() {
    while read -u3 NAME; do
        # install any missing dependencies
        local MISSING="$(brew missing ${NAME})"
        [[ -z "${MISSING}" ]] || brew install ${MISSING}

        # link, if not already
        brew link ${NAME} || true

        # is it pinned?
        brew list ${NAME} --pinned | grep -q "^${NAME}$" && continue || true

        # is it already up-to-date?
        brew outdated ${NAME} >/dev/null 2>&1 || {
            echo_do "brew: Upgrading ${NAME}..."
            brew upgrade ${NAME}
            echo_done
        }
    done 3< <(echo "$@")
}

brew_install() {
    while read -u3 FORMULA; do
        local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1 | sed "s/\.rb$$//")
        local NAME=$(basename "${FULLNAME}")
        local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)
        # is it already installed ?
        if brew list "${NAME}" >/dev/null 2>&1; then
            # do we require installation with specific options ?
            [[ -n "${OPTIONS}" ]] || {
                echo_skip "brew: Installing ${FORMULA}..."
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
    done 3< <(echo "$@")
    # see https://github.com/Homebrew/brew/issues/5013
    hash -r
}

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-ci.inc.sh

brew_brewfile_inc_sh() {
    local BREWFILE_INC_SH=${GIT_ROOT}/Brewfile-${OS_SHORT}.inc.sh
    [[ -f "${BREWFILE_INC_SH}" ]] || BREWFILE_INC_SH=${GIT_ROOT}/Brewfile.inc.sh
    [[ -f "${BREWFILE_INC_SH}" ]] || {
        echo_err "No ${BREWFILE_INC_SH} file present."
        return 1
    }
    echo_info "Sourcing ${BREWFILE_INC_SH}..."
    source ${BREWFILE_INC_SH}
}

brew_list() {
    echo_do "brew: Listing packages..."
    brew list --versions
    echo_done
}

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
