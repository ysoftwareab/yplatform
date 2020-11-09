#!/usr/bin/env bash
set -euo pipefail

function brew_lockfile() {
    local BREWFILE_LOCK=${GIT_ROOT}/Brewfile.lock

    [[ -f "${BREWFILE_LOCK}" ]] || {
        echo_skip "Resetting Homebrew..."
        return 1
    }

    echo_info "Found a ${BREWFILE_LOCK}:"
    cat ${BREWFILE_LOCK}

    local BREW_REMOTE=$(git -C "$(brew --prefix)/Homebrew" remote get-url origin)
    echo_info "Homebrew remote: ${BREW_REMOTE}."

    local BREW_FROM=$(git -C "$(brew --prefix)/Homebrew" rev-list -1 HEAD)
    local BREW_TO=$(cat "${BREWFILE_LOCK}" | grep "^${BREW_REMOTE} " | cut -d" " -f2 || true)
    [[ -z "${BREW_TO}" ]] || {
        local BREW_SHALLOW_SINCE=$(cat "${BREWFILE_LOCK}" | grep "^${BREW_REMOTE} " | cut -d" " -f3-)

        echo_do "Resetting Homebrew..."
        echo_info "Resetting Homebrew from ${BREW_FROM} to ${BREW_TO}."
        echo_info "Unshallow after ${BREW_SHALLOW_SINCE}."
        git -C "$(brew --prefix)/Homebrew" fetch --tags
        git -C "$(brew --prefix)/Homebrew" fetch --shallow-since "${BREW_SHALLOW_SINCE}"
        git -C "$(brew --prefix)/Homebrew" reset --hard "${BREW_TO}"
        echo_info "Reset Homebrew"
        echo_info "from $(git -C "$(brew --prefix)/Homebrew" log -1 --format="%cd" "${BREW_FROM}") ${BREW_FROM}"
        echo_info "to   $(git -C "$(brew --prefix)/Homebrew" log -1 --format="%cd" "${BREW_TO}") ${BREW_TO}"
        echo_done
    }

    (
        cd "$(brew --prefix)/Homebrew/Library/Taps"
        cat ${BREWFILE_LOCK} | grep -v "^${BREW_REMOTE} " | while read -r BREW_TAP_LOCK; do
            TAP_REMOTE=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f1)
            TAP_TO=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f2)
            TAP_SHALLOW_SINCE=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f3-)

            TAP=$(basename $(dirname "${TAP_REMOTE}"))/$(basename "${TAP_REMOTE}")
            TAP=$(echo "${TAP}" | tr "A-Z" "a-z")

            case ${OS_SHORT}-${TAP} in
                darwin-homebrew/linuxbrew-core)
                    echo_skip "Resetting Homebrew tap ${TAP}..."
                    continue
                    ;;
                linux-homebrew/homebrew-core)
                    echo_skip "Resetting Homebrew tap ${TAP}..."
                    continue
                    ;;
                linux-homebrew/homebrew-cask)
                    echo_skip "Resetting Homebrew tap ${TAP}..."
                    continue
                    ;;
                linux-homebrew/linuxbrew-core)
                    TAP=homebrew/homebrew-core
                    ;;
            esac

            [[ -d ${TAP} ]] || {
                echo_do "Installing Homebrew tap ${TAP}..."
                brew tap "${TAP}"
                echo_done
            }

            TAP_FROM=$(git -C "${TAP}" rev-list -1 HEAD)
            echo_do "Resetting Homebrew tap ${TAP}..."
            echo_info "Resetting Homebrew tap ${TAP} from ${TAP_FROM} to ${TAP_TO}."
            echo_info "Unshallow after ${TAP_SHALLOW_SINCE}."
            git -C "${TAP}" fetch --shallow-since "${TAP_SHALLOW_SINCE}"
            git -C "${TAP}" reset --hard "${TAP_TO}"
            echo_info "Reset Homebrew tap ${TAP}"
            echo_info "from $(git -C "${TAP}" log -1 --format="%cd" "${TAP_FROM}") ${TAP_FROM}"
            echo_info "to   $(git -C "${TAP}" log -1 --format="%cd" "${TAP_TO}") ${TAP_TO}"
            echo_done
        done
    )
    echo_done
}

function brew_update() {
    echo_do "brew: Updating..."
    # 'brew update' is currently flaky, resulting in 'transfer closed with outstanding read data remaining'
    # see https://github.com/Homebrew/homebrew-core/issues/61772
    brew update >/dev/null || brew update
    brew outdated
    echo_done
}
