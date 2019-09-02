#!/usr/bin/env bash
set -euo pipefail

function brew_upgrade() {
    while read -u3 NAME; do
        [[ -n "${NAME}" ]] || continue

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

function brew_install() {
    while read -u3 FORMULA; do
        [[ -n "${FORMULA}" ]] || continue

        local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
        local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
        local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

        # is it already installed ?
        if brew list "${NAME}" >/dev/null 2>&1; then
            # is it a url/path to a formula.rb file
            [[ "${FULLNAME}" = "${NAME}" ]] || {
                brew uninstall ${NAME}

                echo_do "brew: Installing ${FORMULA}..."
                brew install ${FORMULA}
                echo_done

                continue
            }

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

function brew_brewfile_inc_sh() {
    local BREWFILE_INC_SH=${GIT_ROOT}/Brewfile.inc.sh
    [[ -f "${BREWFILE_INC_SH}" ]] || {
        echo_err "No ${BREWFILE_INC_SH} file present."
        return 1
    }
    echo_info "Sourcing ${BREWFILE_INC_SH}..."
    source ${BREWFILE_INC_SH}
}

function brew_list() {
    echo_do "brew: Listing packages..."
    brew list --versions
    echo_done
}

# apt_install is not related to brew, but it is here for convenience,
# to make it available in Brewfile.inc.sh files
function apt_install() {
    while read -u3 DPKG; do
        [[ -n "${DPKG}" ]] || continue

        echo_do "aptitude: Installing ${DPKG}..."
        sudo apt-get install -y --force-yes "${DPKG}"
        echo_done
    done 3< <(echo "$@")
}
