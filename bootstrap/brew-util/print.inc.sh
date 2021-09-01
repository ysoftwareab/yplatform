#!/usr/bin/env bash
set -euo pipefail

function brew_system() {
    if command -v screenfetch >/dev/null 2>&1; then
        echo_do "brew: System info from screenfetch..."
        # first stdout, then stderr. see https://unix.stackexchange.com/questions/417124/display-stdouts-before-stderr
        { screenfetch -n -v 2>&1 >&3 3>&- | ${SUPPORT_FIRECLOUD_DIR}/bin/sponge >&2 3>&-; } 3>&1
        echo_done
    fi

    if command -v inxi >/dev/null 2>&1; then
        echo_do "brew: System info from inxi..."
        echo_info "Using inxi."
        inxi -F -xxx
        echo_done
    fi

    if [[ "${OS_SHORT}" = "darwin" ]]; then
        echo_do "brew: System info from system_profiler..."
        # skipping printing everything because it can be very slow
        # system_profiler
        system_profiler SPSoftwareDataType SPDeveloperToolsDataType
        system_profiler SPHardwareDataType SPMemoryDataType SPStorageDataType
        echo_done
    fi
}

# brew_ namespace chosen for consistency, even if less relevant for printenv
function brew_printenv() {
    echo_do "Printenv..."
    if [[ "${SF_PRINTENV_BOOTSTRAP:-}" = "true" ]]; then
        printenv_all
    else
        echo_info "Printing only excerpts of printenv."
                cat <<EOF
^CI=
^CONTINUOUS_INTEGRATION=
        printenv_all | grep -f <(
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
^SF_SUDO=
^TZ=
^USER=
EOF
            )
    fi
    echo_done

    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo_do "Listing git status..."
        git rev-parse --show-toplevel
        git status
        echo_done
    fi

    echo_do "Listing current working directory..."
    pwd
    ls -la $(pwd)
    echo_done

    echo_do "Listing HOME directory..."
    echo ${HOME}
    ls -la ${HOME}
    echo_done
}

function brew_config() {
    echo_do "brew: Printing config..."
    brew config
    echo_done
}

function brew_list() {
    brew_list_installed

    echo_do "brew: Listing dependency tree..."
    brew deps --installed --tree
    echo_done
}
