#!/usr/bin/env bash

[[ "$1" != "debug" ]] || {
    echo
    echo "  Creating a debugging subshell..."
    echo
    PS1="${debian_chroot:+($debian_chroot)}\u:\w\$ " ${SHELL}
    exit 0
}


function sf_ci_run_all() {
    local CI_PHASES="$(cat <<-EOF
before_install
install
before_script
script
EOF
)"

    for f in ${CI_PHASES}; do
        sf_ci_run $f;
    done
}
