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

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util.inc.sh

echo_do "brew: Updating..."
brew update
brew outdated
echo_done

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-ci.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
