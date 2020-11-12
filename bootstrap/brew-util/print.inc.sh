#!/usr/bin/env bash
set -euo pipefail

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

function brew_config() {
    echo_do "brew: Printing config..."
    brew config
    echo_done
}

function brew_list() {
    echo_do "brew: Listing packages..."
    brew list --versions
    echo_done
}
