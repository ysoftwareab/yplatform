#!/usr/bin/env bash
set -euo pipefail

[[ "${YP_CI_PLATFORM:-}" != "github" ]] || {
    [[ "${OS_SHORT}" != "darwin" ]] || {
        echo_do "Uninstalling Python 2.7..."
        set -x
        # uninstall Python 2.7, or else we get symlink conflicts, etc
        ${YP_SUDO} rm -rf /Applications/Python\ 2.7
        ${YP_SUDO} rm -rf /Library/Frameworks/Python.framework
        find /usr/local/bin -type l -print0 | \
            xargs -0 stat -f "%N %Y" | \
            grep "/Library/Frameworks/Python\.framework" | \
            cut -d" " -f1 | while read -r NO_XARGS_R; do
                [[ -n "${NO_XARGS_R}" ]] || continue;
                ${YP_SUDO} rm -rf ${NO_XARGS_R}
            done
        set +x
        echo_done
    }
}

echo_do "brew: Installing CI packages..."
# NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
# NOTE 'findutils' provides 'xargs', because the MacOS version has no 'xargs -r'
brew_install_one_unless findutils "find --version | head -1" "^find (GNU findutils) 4\."
brew_install_one_unless git "git --version | head -1" "^git version 2\."

brew_install_one_unless jq "jq --version | head -1" "^jq-1\."
# install if we're falling back to our jq proxy
[[ -f "${YP_DIR}/bin/.jq/jq" ]]
if_exe_and_grep_q "which jq" "^${YP_DIR}/bin/\.jq/jq$" brew_install_one jq

brew_install_one_unless jd "jd --version | head -1" "^jd version 1\."
# install if we're falling back to our jd proxy
[[ -f "${YP_DIR}/bin/.jd/jd" ]]
if_exe_and_grep_q "which jd" "^${YP_DIR}/bin/\.jd/jd$" brew_install_one jd

brew_install_one_unless yq "yq --version | head -1" " version v4\."
# install if we're falling back to our yq proxy
[[ -f "${YP_DIR}/bin/.yq/yq" ]]
if_exe_and_grep_q "which yq" "^${YP_DIR}/bin/\.yq/yq$" brew_install_one yq

brew_install_one_unless screenfetch "screenfetch --version | head -1" "^.*screenFetch.* - Version 3\."
brew_install_one_unless tmate "tmate -V | head -1" "^tmate 2\."

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
    echo_info "Skipping post-ci bootstrap."
    yp_ci_debug
fi
