#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util.inc.sh

function bootstrap_has_brew() {
    if which brew >/dev/null 2>&1; then
        # using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
        # exe_and_grep_q "brew --version | head -1" "^Homebrew 2." || return 1
        exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 2\." || return 1
    else
        echo_info "brew: Executable brew not found."
        return 1
    fi
}

function bootstrap_brew() {
    local RAW_GUC_URL="https://raw.githubusercontent.com"
    local BREWFILE_LOCK=${GIT_ROOT}/Brewfile.lock
    local BREW_GITREF=master
    local BREW_INSTALL_GITREF=master

    [[ "${CI}" != "true" ]] || {
        [[ ! -f ${BREWFILE_LOCK} ]] || {
            local BREW_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/brew " || true)
            local BREW_GITREF=$(echo "${BREW_LOCK}" | cut -d" " -f2)

            local BREW_INSTALL_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/install " || true)
            [[ -z "${BREW_INSTALL_LOCK}" ]] || {
                local BREW_INSTALL_GITREF=$(echo "${BREW_INSTALL_LOCK}" | cut -d" " -f2)
            }
        }
    }

    local BREW_INSTALL_URL=${RAW_GUC_URL}/Homebrew/install/${BREW_INSTALL_GITREF}

    [[ "${CI}" != "true" ]] || {
        if which brew >/dev/null 2>&1; then
            if [[ "${SF_SKIP_BREW_UNINSTALL:-}" = "true" ]]; then
                echo_skip "brew: Uninstalling homebrew..."
            else
                echo_do "brew: Uninstalling homebrew..."
                </dev/null /bin/bash -c "$(curl -fqsSL ${BREW_INSTALL_URL}/uninstall.sh)"
                echo_done
                hash -r
            fi
        fi
    }

    local HAS_BREW_2=true
    bootstrap_has_brew || HAS_BREW_2=false

    case ${HAS_BREW_2}-${OS_SHORT} in
        false-darwin)
            echo_do "brew: Installing homebrew..."
            (
                # FIXME needed for HOMEBREW_FORCE_BREWED_{CURL,GIT}
                # see https://github.com/Homebrew/install/issues/522
                # shellcheck disable=SC2030,SC2031
                export HOMEBREW_NO_AUTO_UPDATE=
                </dev/null /bin/bash -c "$(curl -fqsSL ${BREW_INSTALL_URL}/install.sh)"
            )
            echo_done
            # see https://github.com/Homebrew/brew/issues/5013
            hash -r
            source ${SUPPORT_FIRECLOUD_DIR}/sh/env.inc.sh
            ;;
        false-linux)
            echo_do "brew: Installing homebrew..."
            if [[ "${SF_SUDO}" = "" ]] || [[ "${SF_SUDO}" = "sf_nosudo" ]]; then
                HOMEBREW_PREFIX=${HOME}/.linuxbrew
                echo_do "brew: Installing without sudo into ${HOMEBREW_PREFIX}..."
                mkdir -p ${HOMEBREW_PREFIX}
                curl -fqsSL https://github.com/Homebrew/brew/tarball/${BREW_GITREF} | \
                    tar xz --strip 1 -C ${HOMEBREW_PREFIX}
                echo_done
            else
                (
                    # FIXME needed for HOMEBREW_FORCE_BREWED_{CURL,GIT}
                    # see https://github.com/Homebrew/install/issues/522
                    # shellcheck disable=SC2030,SC2031
                    export HOMEBREW_NO_AUTO_UPDATE=
                    </dev/null /bin/bash -c "$(curl -fqsSL ${BREW_INSTALL_URL}/install.sh)"
                )
            fi
            echo_done
            # see https://github.com/Homebrew/brew/issues/5013
            hash -r
            source ${SUPPORT_FIRECLOUD_DIR}/sh/env.inc.sh
            ;;
        true-darwin|true-linux)
            ;;
        *)
            echo_err "brew: ${OS_SHORT} is an unsupported OS."
            return 1
            ;;
    esac
}

bootstrap_brew
brew_config

if [[ -f ${GIT_ROOT}/Brewfile.lock ]]; then
    brew_lockfile
else
    brew_update
fi
brew_config
