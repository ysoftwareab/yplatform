#!/usr/bin/env bash
set -euo pipefail

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

# brew_ namespace chosen for consistency, even if less relevant for printenv
function brew_printenv() {
    echo_do "Printenv..."
    if [[ "${SF_PRINTENV_BOOTSTRAP:-}" = "true" ]]; then
        printenv
    else
        echo_info "Printing only excerpts of printenv."
        printenv | grep -f <(
                cat <<EOF
^CI=
^CONTINUOUS_INTEGRATION=
^EDITOR=
^GIT_
^HOME=
^HOMEBREW_NO_
^LANG=
^LANGUAGE=
^LC_ALL=
^LC_CTYPE=
^MANPATH=
^PAGER=
^PATH=
^PWD=
^SHELL=
^SF_LOG_BOOTSTRAP=
^SF_PRINTENV_BOOTSTRAP=
^SUDO=
^TZ=
^USER=
EOF
            )
    fi
    echo_done

    echo_do "Listing current working directory..."
    pwd
    ls -la $(pwd)
    echo_done

    echo_do "Listing HOME directory..."
    echo ${HOME}
    ls -la ${HOME}
    echo_done
}

function brew_update() {
    echo_do "brew: Updating..."
    brew update >/dev/null
    brew outdated
    echo_done
}

function brew_upgrade_one() {
    local FORMULA="$@"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")

    # install any missing dependencies
    local MISSING="$(brew missing ${NAME})"
    [[ -z "${MISSING}" ]] || {
        echo_info "brew: Found missing dependencies for ${NAME}: ${MISSING}."
        echo_do "brew: Installing missing dependencies for ${NAME}..."
        brew install ${MISSING}
        echo_done
    }

    # link, if not already
    echo_do "brew: Linking ${NAME}..."
    if [[ "${CI:-}" != "true" ]]; then
        brew link ${NAME} || true
    else
        brew link --force --overwrite ${NAME} || true
    fi
    echo_done

    # is it pinned?
    if brew list ${NAME} --pinned | grep -q "^${NAME}$"; then
        echo_info "brew: ${NAME} is pinned."
        echo_skip "brew: Upgrading ${NAME}..."
        return 0
    fi

    # is it already up-to-date?
    if ! brew outdated ${NAME} >/dev/null 2>&1; then
        echo_info "brew: ${NAME} is up-to-date."
        echo_skip "brew: Upgrading ${NAME}..."
        return 0
    fi

    echo_do "brew: Upgrading ${NAME}..."
    brew upgrade ${NAME}
    echo_done
}

function brew_upgrade() {
    while read -u3 FORMULA; do
        [[ -n "${FORMULA}" ]] || continue
        brew_upgrade_one "${FORMULA}"
    done 3< <(echo "$@")
}

# install erlang without wxmac bloat
function brew_install_one_erlang() {
    echo_do "brew: Installing erlang, without wxmac..."
    brew tap linuxbrew/xorg
    # using a for loop because 'xargs -r' is not part of the BSD version (MacOS)
    # comm -23 <(brew deps erlang) <(brew deps wxmac) | sed "/^wxmac$/d" | xargs -r -L1 brew install
    for FORMULA in $(comm -23 <(brew deps erlang) <(brew deps wxmac) | sed "/^wxmac$/d"); do
        brew install ${FORMULA}
    done
    brew install --force erlang --ignore-dependencies || brew link --force --overwrite erlang
    echo_done
}

function brew_install_one() {
    local FORMULA="$@"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
    local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

    case ${NAME} in
        erlang)
            brew_install_one_erlang
            return 0
            ;;
        *)
            true
            ;;
    esac

    # is it already installed ?
    if brew list "${NAME}" >/dev/null 2>&1; then
        # is it a url/path to a formula.rb file
        [[ "${FULLNAME}" = "${NAME}" ]] || {
            brew uninstall ${NAME}

            echo_do "brew: Installing ${FORMULA}..."
            if [[ "${CI:-}" != "true" ]]; then
                brew install ${FORMULA}
            else
                brew install --force ${FORMULA} || brew link --force --overwrite ${FORMULA}
            fi
            echo_done

            return 0
        }

        # install without specific options ?
        [[ -n "${OPTIONS}" ]] || {
            echo_skip "brew: Installing ${FORMULA}..."
            brew_upgrade ${NAME}
            return 0
        }

        # is it already installed with the required options ?
        local USED_OPTIONS="$(brew info --json=v1 ${NAME} | \
            /usr/bin/python \
                -c 'import sys,json;print "".join(json.load(sys.stdin)[0]["installed"][0]["used_options"])' | \
            xargs -n 1 | \
            sort -u || true)"
        local NOT_FOUND_OPTIONS="$(comm -23 <(echo "${OPTIONS}") <(echo "${USED_OPTIONS}"))"
        [[ -n "${NOT_FOUND_OPTIONS}" ]] || {
            echo_skip "brew: Installing ${FORMULA}..."
            brew_upgrade ${NAME}
            return 0
        }

        echo_err "${NAME} is already installed with options '${USED_OPTIONS}',"
        echo_err "but not the required '${NOT_FOUND_OPTIONS}'."

        if [[ "${TRAVIS:-}" = "true" ]]; then
            brew uninstall ${NAME}
        else
            echo_err "Consider uninstalling ${NAME} with 'brew uninstall ${NAME}' and rerun the bootstrap!"
            return 1
        fi
    fi

    echo_do "brew: Installing ${FORMULA}..."
    brew install ${FORMULA}
    echo_done
}

function brew_install() {
    while read -u3 FORMULA; do
        [[ -n "${FORMULA}" ]] || continue
        brew_install_one ${FORMULA}
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

# apt-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function apt_update() {
    ${SUDO} apt-get update -y --fix-missing 2>&1 || {
        set -x
        # try to handle "Hash Sum mismatch" error
        ${SUDO} apt-get clean
        ${SUDO} rm -rf /var/lib/apt/lists/*
        # see https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1785778
        ${SUDO} apt-get update -o Acquire::CompressionTypes::Order::=gz
        ${SUDO} apt-get update -y --fix-missing
        set +x
    }
}

function apt_install_one() {
    local DPKG="$@"

    echo_do "aptitude: Installing ${DPKG}..."
    # ${SUDO} apt-get install -y --force-yes ${DPKG}
    ${SUDO} apt-get install -y ${FORCE_YES} ${DPKG}
    echo_done
}

function apt_install() {
    local FORCE_YES="--allow-downgrades --allow-remove-essential --allow-change-held-packages"
    while read -u3 DPKG; do
        [[ -n "${DPKG}" ]] || continue
        apt_install_one ${DPKG}
    done 3< <(echo "$@")
}
