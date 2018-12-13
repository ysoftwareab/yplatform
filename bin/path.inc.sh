#!/usr/bin/env bash

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    export PATH=/home/linuxbrew/.linuxbrew/sbin:${PATH}
    export PATH=/home/linuxbrew/.linuxbrew/bin:${PATH}
elif [[ -x ~/.linuxbrew/bin/brew ]]; then
    export PATH=~/.linuxbrew/sbin:${PATH}
    export PATH=~/.linuxbrew/bin:${PATH}
fi
export PATH=/usr/local/sbin:${PATH}
export PATH=/usr/local/bin:${PATH}
export PATH=${HOME}/.local/sbin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}

if which brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
    export PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}

    for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip make; do
        export PATH=${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin:${PATH}
    done
    export PATH=${HOMEBREW_PREFIX}/opt/curl/bin:${PATH}
    export PATH=${HOMEBREW_PREFIX}/opt/unzip/bin:${PATH}
    unset HOMEBREW_PREFIX
fi
