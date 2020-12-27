#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing GNU packages..."
# NOTE 'bash' >=4 provides functionality like associative arrays, globstar, etc
# see https://tldp.org/LDP/abs/html/bashver4.html
brew_install_one_if bash "bash --version | head -1" "^GNU bash, version [^123]\."
brew_install_one_if coreutils "cat --version | head -1" "^cat (GNU coreutils) 8\."
brew_install_one_if diffutils "diff --version | head -1" "^diff (GNU diffutils) 3\."
# NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
# NOTE 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
brew_install_one_if findutils "find --version | head -1" "^find (GNU findutils) 4\."
# NOTE 'gettext' provides 'envsubst'
brew_install_one_if gettext "envsubst --version | head -1" "^envsubst (GNU gettext-runtime) \(0\.20\|0\.21\)"
brew_install_one_if gnu-sed "sed --version | head -1" "^sed (GNU sed) 4\."
brew_install_one_if gnu-tar "tar --version | head -1" "^tar (GNU tar) 1\."
brew_install_one_if gnu-which "env which --version | head -1" "^GNU which v2\."
brew_install_one_if grep "grep --version | head -1" "^grep (GNU grep) 3\."
brew_install_one_if gzip "gzip --version | head -1" "^gzip 1\."
brew_install_one_if gzip "gzip --version | head -5 | tail -1" "^the GNU General Public License"
# NOTE 'make' >=4 provides functionality for 'make-lazy'
brew_install_one_if make "make --version | head -1" "^GNU Make 4\.3"

# need an extra condition, because the original one fails intermitently
# brew_install_one_if "xargs --help 2>&1" "no-run-if-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    brew_install_one_if findutils "xargs --help 2>&1" "no-run-if-empty"
    exit 1
}
echo_done
