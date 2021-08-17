#!/usr/bin/env bash
set -euo pipefail

[[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
    [[ "${OS_SHORT}" != "darwin" ]] || {
        echo_do "Uninstalling Python 2.7..."
        set -x
        # uninstall Python 2.7, or else we get symlink conflicts, etc
        ${SF_SUDO} rm -rf /Applications/Python\ 2.7
        ${SF_SUDO} rm -rf /Library/Frameworks/Python.framework
        find /usr/local/bin -type l -print0 | \
            xargs -0 stat -f "%N %Y" | \
            grep "/Library/Frameworks/Python\.framework" | \
            cut -d" " -f1 | while read -r NO_XARGS_R; do
                [[ -n "${NO_XARGS_R}" ]] || continue;
                ${SF_SUDO} rm -rf ${NO_XARGS_R}
            done
        set +x
        echo_done
    }
}

echo_do "brew: Installing CI packages..."
# NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
# NOTE 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
brew_install_one_if findutils "find --version | head -1" "^find (GNU findutils) 4\."
brew_install_one_if git "git --version | head -1" "^git version 2\."
brew_install_one_if jq "jq --version | head -1" "^jq-1\."
brew_install_one_if screenfetch "screenfetch --version | head -1" "^.*screenFetch.* - Version 3\."
brew_install_one_if tmate "tmate -V | head -1" "^tmate 2\."

# need an extra condition, because the original one fails intermitently
# exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    exe_and_grep_q "xargs --help 2>&1" "no-run-if-empty"
    exit 1
}
echo_done

if git log -1 --format="%B" | grep -q "\[debug ci\]"; then
    echo_info "Detected '[debug ci]' marker in git commit message."
    echo_info "Starting a tmate session and exiting"

    [[ -n ${SF_TMATE_AUTH:-} ]] || [[ ! -f ${GIT_ROOT}/.tmate.authorized_keys ]] || {
        SF_TMATE_AUTH=${GIT_ROOT}/.tmate.authorized_keys
    }

    [[ -n ${SF_TMATE_AUTH:-} ]] || [[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
        echo_info "Session will be restricted to GITHUB_ACTOR=${GITHUB_ACTOR}."
        # default to github actor's public ssh keys
        SF_TMATE_AUTH=$(mktemp -t firecloud.XXXXXXXXXX)
        exe curl -qfsSL \
            -H "accept: application/vnd.github.v3+json" \
            -H "authorization: token ${SF_GH_TOKEN_DEPLOY}" \
            https://api.github.com/users/${GITHUB_ACTOR}/keys | \
            jq -r ".[].key" > ${SF_TMATE_AUTH}
    }

    if [[ "${SF_TMATE_AUTH:-}" = "none" ]]; then
        echo_warn "Session will be unrestricted due to SF_TMATE_AUTH=${SF_TMATE_AUTH}."
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    elif [[ "${SF_DOCKER:-}" = "true" ]]; then
        echo_warn "Session will be unrestricted due to SF_DOCKER=${SF_DOCKER}."
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    elif [[ -n ${SF_TMATE_AUTH:-} ]]; then
        echo_info "Session will be restricted to SF_TMATE_AUTH=${SF_TMATE_AUTH}."
        cat ${SF_TMATE_AUTH}
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell ${SF_TMATE_AUTH}
    else
        echo_err "No SF_TMATE_AUTH defined. Refusing to start a tmate session open to the world."
        echo_info "Define SF_TMATE_AUTH=none if you really want to."
    fi
    exit 1
fi
