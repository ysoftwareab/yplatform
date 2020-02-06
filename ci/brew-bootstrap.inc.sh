#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

HAS_BREW_2=true
# using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
# exe_and_grep_q "brew --version | head -1" "^Homebrew 2." || HAS_BREW_2=false
exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 2." || HAS_BREW_2=false

RAW_GUC_URL="https://raw.githubusercontent.com"

case $(uname -s) in
    Darwin)
        if [[ "${HAS_BREW_2}" = "true" ]]; then
            brew update
        else
            echo_do "brew: Installing homebrew..."
            </dev/null ruby -e "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/install)"
            echo_done
        fi

        CI_CACHE_HOMEBREW_PREFIX=~/.homebrew
        ;;
    Linux)
        if [[ "${HAS_BREW_2}" = "true" ]]; then
            brew update
        else
            echo_do "brew: Installing linuxbrew..."
            if [[ "${SUDO}" = "" ]] || [[ "${SUDO}" = "sf_nosudo" ]]; then
                HOMEBREW_PREFIX=~/.linuxbrew
                echo_do "brew: Installing without sudo into ${HOMEBREW_PREFIX}..."
                mkdir -p ${HOMEBREW_PREFIX}
                curl -fqsS -L https://github.com/Homebrew/brew/tarball/master | \
                    tar xz --strip 1 -C ${HOMEBREW_PREFIX}
                echo_done
            else
                </dev/null sh -c "$(curl -fqsS -L ${RAW_GUC_URL}/Linuxbrew/install/master/install.sh)"
            fi
            echo_done
        fi

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

[[ "${CI:-}" != "true" ]] || {
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util.inc.sh
    brew_update
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-ci.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
