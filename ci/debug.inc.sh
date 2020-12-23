#!/usr/bin/env bash

[[ "${1:-}" != "debug" ]] || {
    echo
    echo "  You can run specific stages like"
    echo "  ./.ci.sh before_install"
    echo "  or you can run them all (before_install, install, before_script, script)"
    echo "  ./.ci.sh all"
    echo
    export CI_DEBUG_MODE=true

    # export all functions $(e.g. nvm)
    source <(declare -F | sed "s/^declare /export /g")

    # PS1="${debian_chroot:+($debian_chroot)}\u\w\$ " bash
    PS1="\w\$ " bash
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
        sf_ci_run ${f};
    done
}
