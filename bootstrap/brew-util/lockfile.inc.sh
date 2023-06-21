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

    local BREW_FROM=$(git -C "$(brew --repository)" rev-list -1 HEAD)
    local BREW_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/brew " || true)
    if [[ -z "${BREW_LOCK}" ]]; then
        echo_skip "Resetting Homebrew..."
    else
        # TODO check wsl version; fix only for WSLv1
        # see https://github.com/orgs/Homebrew/discussions/4112
        if ${YP_DIR}/bin/is-wsl; then
            BREW_LOCK=refs/tags/3.6.7
            echo_warn "Ignoring ${BREWFILE_LOCK} for homebrew/brew on WSL. Using ${BREW_LOCK}."
        fi
        local BREW_TO=$(echo "${BREW_LOCK}" | cut -d" " -f2 | sed "s|^refs/heads/|refs/remotes/origin/|")

        echo_do "Resetting Homebrew..."
        echo_info "Resetting Homebrew from ${BREW_FROM} to ${BREW_TO}."
        git -C "$(brew --repository)" fetch --tags
        git -C "$(brew --repository)" fetch
        git -C "$(brew --repository)" reset --hard "${BREW_TO}"
        echo_info "Reset Homebrew"
        echo_info "from $(git -C "$(brew --repository)" log -1 --format="%cd" "${BREW_FROM}") ${BREW_FROM}"
        echo_info "to   $(git -C "$(brew --repository)" log -1 --format="%cd" "${BREW_TO}") ${BREW_TO}"
        echo_done
    fi

    (
        mkdir -p "$(brew --repository)/Library/Taps"
        cd "$(brew --repository)/Library/Taps"
        cat ${BREWFILE_LOCK} | \
            grep -v "^homebrew/brew " | \
            grep -v "^homebrew/install " | \
            while read -r BREW_TAP_LOCK; do
            TAP=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f1)
            TAP_TO=$(echo "${BREW_TAP_LOCK}" | cut -d" " -f2 | sed "s|^refs/heads/|refs/remotes/origin/|")

            case "${OS_SHORT}-${TAP}" in
                linux-homebrew/homebrew-cask)
                    echo_skip "Resetting Homebrew tap ${TAP}..."
                    continue
                    ;;
                *)
                    echo_info "OS_SHORT=${OS_SHORT} TAP=${TAP}"
                    ;;
            esac

            [[ -d ${TAP} ]] || {
                echo_do "Installing Homebrew tap ${TAP}..."
                # NOTE calling 'brew tap' may surface incompatibility issues between our locked-version of brew
                # and the tap-expected-version of brew
                # brew tap "${TAP}"
                mkdir -p "${TAP}"
                if [[ "${CI:-}" = "true" ]] && git --version | grep -q "^git version 2\.\(\|2[6-9]\|[3-9][0-9]\)\."; then # editorconfig-checker-disable-line
                    (
                        cd "${TAP}"
                        ${YP_DIR}/bin/degit \
                            --history \
                            "https://github.com/${TAP}.git#${TAP_TO/refs\/remotes\/origin/refs\/heads}"
                    )
                else
                    git clone "https://github.com/${TAP}.git" "${TAP}"
                fi
                echo_done
            }

            TAP_FROM=$(git -C "${TAP}" rev-list -1 HEAD)
            if [[ "${TAP_FROM}" != "${TAP_TO}" ]]; then
                echo_do "Resetting Homebrew tap ${TAP}..."
                echo_info "Resetting Homebrew tap ${TAP} from ${TAP_FROM} to ${TAP_TO}."
                git -C "${TAP}" fetch
                git -C "${TAP}" reset --hard "${TAP_TO}"
                echo_info "Reset Homebrew tap ${TAP}"
                echo_info "from $(git -C "${TAP}" log -1 --format="%cd" "${TAP_FROM}") ${TAP_FROM}"
                echo_info "to   $(git -C "${TAP}" log -1 --format="%cd" "${TAP_TO}") ${TAP_TO}"
                echo_done
            else
                echo_skip "Resetting Homebrew tap ${TAP} from ${TAP_FROM} to ${TAP_TO}."
            fi

            # in case we manually git-cloned the tap
            brew tap "${TAP}"
        done
    )
}
