#!/usr/bin/env bash
set -euo pipefail

function bootstrap_has_brew() {
    if command -v brew >/dev/null 2>&1; then
        # using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
        # exe_and_grep_q "brew --version | head -1" "^Homebrew 3." || return 1
        exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 3\." || return 1
        echo_info "brew: Executable brew v3 found."
    else
        echo_info "brew: Executable brew v3 not found."
        return 1
    fi
}

function bootstrap_brew() {
    local RAW_GUC_URL="https://raw.githubusercontent.com"
    local BREWFILE_LOCK=${GIT_ROOT}/Brewfile.lock

    local BREW_INSTALL_GIT_REF=refs/heads/master
    local BREW_GIT_REF=refs/heads/master
    local BREW_CORE_GIT_REF=refs/heads/master

    [[ "${CI}" != "true" ]] || {
        [[ ! -f ${BREWFILE_LOCK} ]] || {
            BREW_INSTALL_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/install " || true)
            [[ -z "${BREW_INSTALL_LOCK}" ]] || \
                BREW_INSTALL_GIT_REF=$(echo "${BREW_INSTALL_LOCK}" | cut -d" " -f2)

            BREW_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/brew " || true)
            [[ -z "${BREW_LOCK}" ]] || \
                BREW_GIT_REF=$(echo "${BREW_LOCK}" | cut -d" " -f2)

            case "${OS_SHORT}" in
                darwin|linux)
                    BREW_CORE_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/homebrew-core " || true)
                    ;;
                *)
                    echo_err "OS_SHORT=${OS_SHORT}"
                    ;;
            esac
            [[ -z "${BREW_CORE_LOCK}" ]] || \
                BREW_CORE_GIT_REF=$(echo "${BREW_CORE_LOCK}" | cut -d" " -f2)
        }
    }

    # bootstrap/brew-util/homebrew-install.sh
    export HOMEBREW_BREW_GIT_REF=$(echo ${BREW_GIT_REF} | sed "s|^refs/heads/|refs/remotes/origin/|")
    export HOMEBREW_CORE_GIT_REF=$(echo ${BREW_CORE_GIT_REF} | sed "s|^refs/heads/|refs/remotes/origin/|")

    BREW_INSTALL_GIT_REF=$(echo ${BREW_INSTALL_GIT_REF} | sed "s|^refs/heads/||" | sed "s|^refs/tags/||")
    BREW_GIT_REF=$(echo ${BREW_GIT_REF} | sed "s|^refs/heads/||" | sed "s|^refs/tags/||")
    BREW_CORE_GIT_REF=$(echo ${BREW_CORE_GIT_REF} | sed "s|^refs/heads/||" | sed "s|^refs/tags/||")

    local BREW_INSTALL_URL=${RAW_GUC_URL}/Homebrew/install/${BREW_INSTALL_GIT_REF}

    [[ "${CI}" != "true" ]] || {
        if command -v brew >/dev/null 2>&1; then
            if [[ "${YP_SKIP_BREW_UNINSTALL:-}" = "true" ]]; then
                echo_skip "brew: Uninstalling homebrew..."
            else
                echo_do "brew: Uninstalling homebrew..."
                </dev/null /bin/bash -c "$(curl -qfsSL ${BREW_INSTALL_URL}/uninstall.sh)"
                echo_done
                hash -r
            fi
        fi
    }

    local HAS_BREW=true
    bootstrap_has_brew || HAS_BREW=false

    case ${HAS_BREW}-${OS_SHORT}-${YP_SUDO:-false} in
        true-darwin-*|true-linux-*)
            echo_skip "brew: Installing homebrew..."
            ;;
        false-linux-false|false-linux-yp_nosudo|false-linux-yp_nosudo_fallback)
            HOMEBREW_PREFIX=${HOME}/.linuxbrew
            echo_do "brew: Installing homebrew without sudo into ${HOMEBREW_PREFIX}..."
            mkdir -p ${HOMEBREW_PREFIX}
            curl -qfsSL https://github.com/Homebrew/brew/tarball/${BREW_GIT_REF} | \
                tar xz --strip 1 -C ${HOMEBREW_PREFIX}
            echo_done
            # see https://github.com/Homebrew/brew/issues/5013
            hash -r
            source ${YP_DIR}/sh/env.inc.sh
            ;;
        false-darwin-*|false-linux-*)
            echo_do "brew: Installing homebrew..."
            (
                # FIXME needed for HOMEBREW_FORCE_BREWED_{CURL,GIT}
                # see https://github.com/Homebrew/install/issues/522
                # shellcheck disable=SC2030,SC2031
                export HOMEBREW_NO_AUTO_UPDATE=
                # </dev/null /bin/bash -c "$(curl -qfsSL ${BREW_INSTALL_URL}/install.sh)"
                </dev/null /bin/bash -c "$(cat ${YP_DIR}/bootstrap/brew-util/homebrew-install.sh)"
            )
            echo_done
            # see https://github.com/Homebrew/brew/issues/5013
            hash -r
            source ${YP_DIR}/sh/env.inc.sh
            ;;
        *)
            echo_err "brew: Cannot handle HAS_BREW=${HAS_BREW} OS_SHORT=${OS_SHORT} YP_SUDO=${YP_SUDO}."
            return 1
            ;;
    esac
}

bootstrap_brew
brew_config

[[ "${OS_RELEASE_ID}" != "alpine" ]] || apk list --installed | grep -q glibc || {
    apk_install_one libc6-compat # skipped in bootstrap/bootstrap-sudo-alpine
    # NOTE as per https://github.com/Linuxbrew/docker/blob/2c7ecfe/alpine/Dockerfile
    brew install -s patchelf
    brew install --ignore-dependencies binutils gmp isl@0.18 libmpc linux-headers mpfr zlib
    brew install --ignore-dependencies gcc || true
    brew install glibc
    brew postinstall gcc
    brew remove patchelf
    brew install -s patchelf
}

if [[ -f ${GIT_ROOT}/Brewfile.lock ]]; then
    brew_lockfile
else
    brew_update
fi
brew_config
