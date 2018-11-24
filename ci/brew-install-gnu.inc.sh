#!/usr/bin/env bash
set -euo pipefail

BREW_WITH_DEFAULT_NAMES=
if [[ "$(uname -s)" = "Darwin" ]]; then
    if [[ "${TRAVIS:-}" = "true" ]]; then
        # speed up by using bottles (no --with-default-names) and changing PATH
        for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip; do
            echo "export PATH=$(brew --prefix)/opt/${f}/libexec/gnubin:${PATH}" > ~/.brew_env
        done
    else
        BREW_WITH_DEFAULT_NAMES="--with-default-names"
    fi
fi

echo_do "brew: Installing GNU packages..."
BREW_FORMULAE="$(cat <<-EOF
autoconf
automake
coreutils
diffutils
findutils ${BREW_WITH_DEFAULT_NAMES}
gnu-sed ${BREW_WITH_DEFAULT_NAMES}
gnu-tar ${BREW_WITH_DEFAULT_NAMES}
gnu-time ${BREW_WITH_DEFAULT_NAMES}
gnu-which ${BREW_WITH_DEFAULT_NAMES}
grep ${BREW_WITH_DEFAULT_NAMES}
gzip
parallel
pkg-config
unzip
watch
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE BREW_WITH_DEFAULT_NAMES
echo_done

# FIXME
# remove autoconf
# remove automake
# remove parallel
# remove pkg-config
# remove watch
