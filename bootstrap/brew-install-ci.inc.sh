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
    ! ${YP_DIR}/bin/is-wsl || {
        brew ls | grep -q "\binutils\b" || {
            echo_info "Pouring binutils 2.40 will freeze windows-2022. Downgrading to 2.39."
            echo_do "Downgrading homebrew Formula binutils to 2.39_1 bottle..."
            BINUTILS_RB_SHA=c55866fa1e75c9de2df980a20279b20a23525e9a
            curl -qfsSL -o binutils.rb \
                https://github.com/Homebrew/homebrew-core/raw/${BINUTILS_RB_SHA}/Formula/binutils.rb
            unset BINUTILS_RB_SHA
            mv binutils.rb $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/
            brew install binutils
            echo_done
        }
        brew pin binutils

        brew ls | grep -q "\icu4c\b" || {
            echo_info "Pouring icu4c 72.1 will freeze windows-2022. Downgrading to 71.1."
            echo_do "Downgrading homebrew Formula icu4c to 12.1 bottle..."
            ICU4C_RB_SHA=e3317b86c11c644e88c762e03eb7b310c3337587
            curl -qfsSL -o icu4c.rb \
                https://github.com/Homebrew/homebrew-core/raw/${ICU4C_RB_SHA}/Formula/icu4c.rb
            unset ICU4C_RB_SHA
            mv icu4c.rb $(brew --prefix)/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/
            brew install icu4c
            echo_done
        }
        brew pin icu4c
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
