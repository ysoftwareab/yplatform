#!/usr/bin/env bash
set -euo pipefail

function brew_list_installed() {
    echo_do "brew: Listing packages..."
    brew list --versions
    echo_done
}
function brew_cache_prune() {
    echo_do "brew: Pruning cache in $(brew --cache)..."
    ${SF_SUDO:-} rm -rf "$(brew --cache)"
    echo_done
}

function brew_install_one() {
    local FORMULA="$*"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
    local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

    # is it already installed ?
    if brew list "${NAME}" >/dev/null 2>&1; then
        # is it a url/path to a formula.rb file
        [[ "${FULLNAME}" = "${FULLNAME%.rb}" ]] || {
            brew uninstall ${NAME}

            echo_do "brew: Installing ${FORMULA}..."
            if [[ "${CI:-}" != "true" ]]; then
                CI="" brew install ${FORMULA}
            else
                CI="" brew install --force ${FORMULA} || brew link --force --overwrite ${NAME}
            fi
            brew info --json=v1 ${NAME} | \
                jq -r ".[0].linked_keg" | \
                grep -q -v "^null$" || \
                brew link --force --overwrite ${NAME}
            echo_done

            return 0
        }

        # install without specific options ?
        [[ -n "${OPTIONS}" ]] || {
            # NOTE true when up-to-date, false otherwise
            if brew outdated ${NAME} >/dev/null; then
                echo_skip "brew: Installing ${FORMULA}..."
                return 0
            else
                brew uninstall --ignore-dependencies ${NAME}
            fi
        }

        # is it already installed with the required options ?
        local USED_OPTIONS="$(brew info --json=v1 ${NAME} | \
            jq -r ".[0].installed[0].used_options" | \
            xargs -n 1 | \
            sort -u || true)"
        local NOT_FOUND_OPTIONS="$(comm -23 <(echo "${OPTIONS}") <(echo "${USED_OPTIONS}"))"
        [[ -n "${NOT_FOUND_OPTIONS}" ]] || {
            # NOTE true when up-to-date, false otherwise
            if brew outdated ${NAME} >/dev/null; then
                echo_skip "brew: Installing ${FORMULA}..."
                return 0
            else
                brew uninstall --ignore-dependencies ${NAME}
            fi
        }

        echo_err "${NAME} is already installed with options '${USED_OPTIONS}',"
        echo_err "but not the required '${NOT_FOUND_OPTIONS}'."

        if [[ "${TRAVIS:-}" = "true" ]]; then
            brew uninstall --ignore-dependencies ${NAME}
        else
            echo_err "Consider uninstalling ${NAME} with 'brew uninstall ${NAME}' and rerun the bootstrap!"
            return 1
        fi
    fi

    echo_do "brew: Installing ${FORMULA}..."
    CI="" brew install ${FORMULA}
    # brew info --json=v1 ${NAME} | \
    #     jq -r ".[0].linked_keg" | \
    #     grep -q -v "^null$" || \
    #     brew link --force --overwrite ${NAME}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function brew_install_one_unless() {
    local FORMULA="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "brew: Installing ${FORMULA}..."
    else
        brew_install_one "${FORMULA}"
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}

function brew_update() {
    echo_do "brew: Updating..."
    # 'brew update' is currently flaky, resulting in 'transfer closed with outstanding read data remaining'
    # see https://github.com/Homebrew/homebrew-core/issues/61772
    brew update >/dev/null || brew update --verbose
    brew outdated
    echo_done
}
