#!/usr/bin/env sh

function path_prepend() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=$1:${PATH}
}

function path_append() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=${PATH}:$1
}

# remove homebrew (linuxbrew) from PATH which is appended, not prepended (default homebrew behaviour)
# see https://github.com/actions/virtual-environments/pull/789
[[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/bin:||" | sed "s|::|:|")
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/sbin:||" | sed "s|::|:|")
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    path_prepend /home/linuxbrew/.linuxbrew/sbin
    path_prepend /home/linuxbrew/.linuxbrew/bin
elif [ -x ~/.linuxbrew/bin/brew ]; then
    path_prepend ${HOME}/.linuxbrew/sbin
    path_prepend ${HOME}/.linuxbrew/bin
fi
path_prepend /usr/local/sbin
path_prepend /usr/local/bin
path_prepend ${HOME}/.local/sbin
path_prepend ${HOME}/.local/bin

if which brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
    path_prepend ${HOMEBREW_PREFIX}/sbin
    path_prepend ${HOMEBREW_PREFIX}/bin

    for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip make; do
        path_prepend ${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin
    done
    path_prepend ${HOMEBREW_PREFIX}/opt/curl/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/gettext/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/unzip/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/zip/bin

    unset HOMEBREW_PREFIX
fi

if type make | grep -e "alias|function"; then
    echo >&2 "[INFO] Refusing to overload 'make' with support-firecloud/sh/exe-env.inc.sh:make."
    echo >&2 "[INFO] It is already overloaded by an alias/function: $(type make)."
else
    function make() {
        [[ -x make.sh ]] || [[ -n "${SF_MAKE_SH_PASS:-}" ]] || {
            $(command -v make) $@
            return $?
        }
        echo >&2 "[INFO] Found a ${PWD}/make.sh. Executing that instead of $(command -v make)."
        export SF_MAKE_SH_PASS=1
        ./make.sh $@
    }
fi
