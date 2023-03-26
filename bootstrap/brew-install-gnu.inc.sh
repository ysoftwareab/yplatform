#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing GNU packages..."
# NOTE install autoconf/automake via Brewfile.inc.sh when needed (depends on perl on linux)
! command -v perl >/dev/null 2>&1 || {
    brew_install_one_unless autoconf "autoconf --version | head -1" "^autoconf (GNU Autoconf) 2\."
    brew_install_one_unless automake "automake --version | head -1" "^automake (GNU automake) 1\."
}
# NOTE 'bash' >=4 provides functionality like associative arrays, globstar, etc
# see https://tldp.org/LDP/abs/html/bashver4.html
brew_install_one_unless bash "bash --version | head -1" "^GNU bash, version [^123]\."
brew_install_one_unless coreutils "cat --version | head -1" "^cat (GNU coreutils) [89]\."
brew_install_one_unless diffutils "diff --version | head -1" "^diff (GNU diffutils) 3\."
# NOTE 'findutils' provides 'find' with '-min/maxdepth' and '-printf'
# NOTE 'findutils' provides 'xargs', because the MacOS version has no 'xargs -r'
brew_install_one_unless findutils "find --version | head -1" "^find (GNU findutils) 4\."
brew_install_one_unless gawk "awk --version | head -1" "^GNU Awk 5\."
# NOTE 'gettext' provides 'envsubst'
brew_install_one_unless gettext "envsubst --version | head -1" "^envsubst (GNU gettext-runtime) 0\.2[01]"
brew_install_one_unless gnu-getopt "getopt --version | head -1" "^getopt from util-linux 2\."
brew_install_one_unless gnu-sed "sed --version | head -1" "\bsed (GNU sed) 4\."
brew_install_one_unless gnu-tar "tar --version | head -1" "^tar (GNU tar) 1\."
brew_install_one_unless gnu-time "env time --version | head -1" "^time (GNU Time) 1\."
brew_install_one_unless gnu-which "env which --version | head -1" "^GNU which v2\."
brew_install_one_unless gpatch "patch --version | head -1" "^GNU patch 2\."
brew_install_one_unless grep "grep --version | head -1" "^grep (GNU grep) 3\."
brew_install_one_unless gzip "gzip --version | head -1" "^gzip 1\."
brew_install_one_unless gzip "gzip --version | head -5 | tail -1" "^the GNU General Public License"
# NOTE 'make' >=4 provides functionality for 'make-lazy'
brew_install_one_unless make "make --version | head -1" "^GNU Make 4\.3"
brew_install_one_unless nano "nano --version | head -1" "^GNU nano, version [67]\."
brew_install_one_unless screen "screen --version | head -1" "^Screen version 4\."
brew_install_one_unless wdiff "wdiff --version | head -1" "^wdiff (GNU wdiff) 1\."
# NOTE use curl instead of wget; 'brew install wget' adds ~100MB (linuxbrew)
# brew_install_one_unless wget "wget --version | head -1" "^GNU Wget 1\."

# need an extra condition, because the original one fails intermitently
# brew_install_one_unless "xargs --help 2>&1" "no-run-if-empty"
echo | xargs -r false || {
    echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
    brew_install_one_unless findutils "xargs --help 2>&1" "no-run-if-empty"
    exit 1
}
echo_done
