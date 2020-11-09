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

    local BREW_FROM=$(git -C "$(brew --prefix)/Homebrew" rev-list -1 HEAD)
    local BREW_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^brew " || true)
    if [[ -z "${BREW_LOCK}" ]]; then
        echo_skip "Resetting Homebrew..."
    else
        local BREW_TO=$(echo "${BREW_LOCK}" | cut -d" " -f2)
        local BREW_SHALLOW_SINCE=$(echo "${BREW_LOCK}" | cut -d" " -f3-)

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
    fi

    (
        cd "$(brew --prefix)/Homebrew/Library/Taps"
        cat ${BREWFILE_LOCK} | grep -v "^brew " | while read -r BREW_TAP_LOCK; do
            TAP=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f1)
            TAP_TO=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f2)
            TAP_SHALLOW_SINCE=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f3-)

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
                    echo_info "'homebrew/homebrew-core' is an alias for 'homebrew/linuxbrew-core' on $(OS_SHORT)."
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
