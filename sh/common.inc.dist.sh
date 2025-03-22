# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (sh/common.inc.dist.sh.tpl)
# ------------------------------------------------------------------------------

#!/usr/bin/env bash
set -euo pipefail

[[ -n "${YP_DIR:-}" ]] || \
    export YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"

# shellcheck disable=SC2128
if [[ -z "${BASH_VERSINFO}" ]] || [[ -z "${BASH_VERSINFO[0]}" ]] || [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Your Bash version is ${BASH_VERSINFO[0]}. ${0} may require >= 4.";
fi


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/core.inc.sh
# BEGIN sh/core.inc.sh
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail
# https://saveriomiroddi.github.io/Additional-shell-options-for-non-trivial-bash-shell-scripts/
shopt -s inherit_errexit 2>/dev/null || true

# stop 'cd' from printing absolute path
unset CDPATH

# see https://www.shell-tips.com/bash/debug-script/
function on_error() {
    local EXIT_STATUS=$1
    >&2 echo "The following BASH_COMMAND exited with status ${EXIT_STATUS}."
    >&2 echo "=${BASH_COMMAND}"

    # best effort
    >&2 echo "~$(eval echo "${BASH_COMMAND}")" || true

    # repeat the exact command in case the line above expands to a lot of output
    # which makes it hard to find the culprit
    >&2 echo "=${BASH_COMMAND}"
    >&2 echo "The above BASH_COMMAND exited with status ${EXIT_STATUS}."

    case ${EXIT_STATUS} in
        127) # command not found
            # NOTE I'm not sure if this will be the correct PATH though, or just based on the context of 'on_error'
            >&2 echo "PATH=${PATH}"
            ;;
        *)
            ;;
    esac
    # see https://bashwizard.com/function-call-stack-and-backtraces/
    for i in "${!BASH_SOURCE[@]}"; do
        # NOTE i=1 instead of i=0 to skip printing info about our 'on_error' function
        # see https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#index-BASH_005fLINENO
        [[ "${i}" != "0" ]] || continue
        >&2 echo "${i}. ${BASH_SOURCE[${i}]}: line ${BASH_LINENO[${i}-1]}: ${FUNCNAME[${i}]}"
    done
    >&2 echo "---"
}
trap 'on_error $?' ERR
set -o errtrace -o functrace

CI="${CI:-}"
[[ "${CI}" != "1" ]] || CI=true

V="${V:-${VERBOSE:-}}"
VERBOSE="${V}"
[[ "${VERBOSE}" != "1" ]] || VERBOSE=true

# [[ "${CI}" != "true" ]] || {
#     # VERBOSE=true
# }

if [[ -n "${VERBOSE}" ]]; then
    [[ "${VERBOSE}" != "2" ]] || {
        VERBOSE=true
        # see https://www.runscripts.com/support/guides/scripting/bash/debugging-bash/verbose-tracing
        export PS4='+ $(date +"%Y-%m-%d %H:%M:%S") +${SECONDS}s ${BASH_SOURCE[0]:-cli}:${LINENO} + '
    }
    set -x
    if [[ "${VERBOSE}" != "true" ]]; then
        exec {BASH_XTRACEFD}> >(tee -a "${VERBOSE}" >&2)
        export BASH_XTRACEFD
    fi
fi
# END sh/core.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/sudo.inc.sh
# BEGIN sh/sudo.inc.sh
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

function yp_nosudo() {
    >&2 echo "$(date +"%H:%M:%S")" "[ERR ] sudo required, but not available for running the following command:"
    >&2 echo "                sudo $*"
    prompt_q_to_continue "Run the command yourself as root, then continue."
}
export -f yp_nosudo

if printenv | grep -q "^YP_SUDO="; then
    # Don't change if already set and exported.
    # NOTE 'test -v YP_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    true
else
    YP_SUDO="$(command -v sudo 2>/dev/null || true)"
    if [[ -z "${YP_SUDO}" ]]; then
        if [[ "${EUID}" = "0" ]]; then
            # Root user doesn't need sudo.
            true
        else
            # The user has no sudo installed.
            YP_SUDO=yp_nosudo_fallback
            function yp_nosudo_fallback() {
                yp_nosudo "$@"
            }
            export -f yp_nosudo_fallback
        fi
    fi
fi
# END sh/sudo.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/os.inc.sh
# BEGIN sh/os.inc.sh
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

ARCH=$(uname -m)
# https://github.com/containerd/containerd/blob/f2c3122e9c6470c052318497899b290a5afc74a5/platforms/platforms.go#L88-L94
# https://github.com/BretFisher/multi-platform-docker-build
ARCH_NORMALIZED=$(echo "${ARCH}" | sed \
    -e "s|^aarch64$|arm64|" \
    -e "s|^arm64/v8$|arm64|" \
    -e "s|^armhf$|arm|" \
    -e "s|^arm64/v7$|arm|" \
    -e "s|^armel$|arm/v6|" \
    -e "s|^i386$|386|" \
    -e "s|^i686$|386|" \
    -e "s|^x86_64$|amd64|" \
    -e "s|^x86-64$|amd64|" \
)
ARCH_SHORT=$(echo "${ARCH}" | grep -q "64" && echo "x64" || echo "x86")
ARCH_BIT=$(echo "${ARCH}" | grep -q "64" && echo "64" || echo "32")

OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
# END sh/os.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/os-release.inc.sh
# BEGIN sh/os-release.inc.sh
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

case ${OS_SHORT} in
    darwin)
        OS_RELEASE_VERSION_ID=$(sw_vers -productVersion)
        # OS_RELEASE_VERSION_ID=$(sysctl -n kern.osproductversion)

        SETUP_ASSISTANT_APP_DIR="/System/Library/CoreServices/Setup Assistant.app"
        OS_RELEASE_ID_CODENAME=$(cat "${SETUP_ASSISTANT_APP_DIR}/Contents/Resources/en.lproj/OSXSoftwareLicense.html" | grep "SOFTWARE LICENSE AGREEMENT FOR" | sed "s/.*FOR //" | sed "s/<.*//") # editorconfig-checker-disable-line
        OS_RELEASE_ID=$(echo "${OS_RELEASE_ID_CODENAME}" | cut -d" " -f1 | tr "[:upper:]" "[:lower:]")
        # shellcheck disable=SC2018
        OS_RELEASE_VERSION_CODENAME=$(echo "${OS_RELEASE_ID_CODENAME}" | cut -d" " -f2- | tr "[:upper:]" "[:lower:]" | tr -cd "a-z") # editorconfig-checker-disable-line
        unset SETUP_ASSISTANT_APP_DIR
        unset OS_RELEASE_ID_CODENAME
        ;;
    linux)
        # see https://unix.stackexchange.com/a/6348/61053
        if [[ -e /etc/os-release ]]; then
            # shellcheck disable=SC1091
            OS_RELEASE_ID=$(source /etc/os-release && echo ${ID:-} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_ID=$(source /etc/os-release && echo ${VERSION_ID:-0} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_CODENAME=$(source /etc/os-release && echo ${VERSION_CODENAME:-} | tr "[:upper:]" "[:lower:]") # editorconfig-checker-disable-line
        elif type lsb_release >/dev/null 2>&1; then
            # linuxbase.org
            OS_RELEASE_ID=$(lsb_release -si | tr "[:upper:]" "[:lower:]")
            OS_RELEASE_VERSION_ID=$(lsb_release -sr)
            OS_RELEASE_VERSION_CODENAME=$(lsb_release -sc | tr "[:upper:]" "[:lower:]")
        elif [[ -f /etc/lsb-release ]]; then
            # shellcheck disable=SC1091
            OS_RELEASE_ID=$(source /etc/lsb-release && echo ${DISTRIB_ID:-} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_ID=$(source /etc/lsb-release && echo ${DISTRIB_RELEASE:-0} | tr "[:upper:]" "[:lower:]")
            # shellcheck disable=SC1091
            OS_RELEASE_VERSION_CODENAME=$(source /etc/lsb-release && echo ${DISTRIB_CODENAME:-} | tr "[:upper:]" "[:lower:]") # editorconfig-checker-disable-line
        fi
        ;;
    *)
        OS_RELEASE_ID=
        OS_RELEASE_VERSION_ID=0
        OS_RELEASE_VERSION_CODENAME=
        ;;
esac
# END sh/os-release.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/git.inc.sh
# BEGIN sh/git.inc.sh
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

# sync with  mk/git.inc.mk

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_BRANCH_SHORT=$(basename "${GIT_BRANCH}" 2>/dev/null || true)
GIT_COMMIT_MSG=$(git log -1 --format="%B" 2>/dev/null || true)
GIT_DESCRIBE=$(git describe --tags --first-parent --always --dirty 2>/dev/null || true)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null || true)
GIT_TAGS=$(git tag --points-at HEAD 2>/dev/null || true)
GIT_TAG=$(git tag --points-at HEAD 2>/dev/null | head -n1 || true)

[[ -z "${SEMAPHORE_GIT_BRANCH:-}" ]] || {
    GIT_BRANCH=${SEMAPHORE_GIT_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${SEMAPHORE_GIT_BRANCH})
}

[[ -z "${TRAVIS_BRANCH:-}" ]] || {
    GIT_BRANCH=${TRAVIS_BRANCH}
    GIT_BRANCH_SHORT=$(basename ${TRAVIS_BRANCH})
}

GIT_REMOTE=$(git config branch.${GIT_BRANCH}.remote 2>/dev/null || true)
GIT_REMOTE_OR_ORIGIN=${GIT_REMOTE:-origin}
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)

GIT_REPO_HAS_CHANGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -v -e "^$$" && \
    echo true || echo false)
GIT_REPO_HAS_STAGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^[^ U\?]" && \
    echo true || echo false)
GIT_REPO_HAS_UNSTAGED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^ [^ ]" && \
    echo true || echo false)
GIT_REPO_HAS_UNTRACKED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^?\?" && \
    echo true || echo false)
GIT_REPO_HAS_CONFLICTS=$(git status --porcelain 2>/dev/null | grep -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
    echo true || echo false)

GIT_REMOTE_URL=$(git config remote.${GIT_REMOTE}.url 2>/dev/null || true)
GIT_REMOTE_SLUG=$(test -z "${GIT_REMOTE_URL}" || GIT_REMOTE_URL=${GIT_REMOTE_URL} basename $(dirname "${GIT_REMOTE_URL//://}"))/$(basename "${GIT_REMOTE_URL}" .git) # editorconfig-checker-disable-line

GIT_REMOTE_OR_ORIGIN_URL=$(git config remote.${GIT_REMOTE_OR_ORIGIN}.url 2>/dev/null || true)
GIT_REMOTE_OR_ORIGIN_SLUG=$(test -z ${GIT_REMOTE_OR_ORIGIN_URL} || GIT_REMOTE_OR_ORIGIN_URL=${GIT_REMOTE_OR_ORIGIN_URL} basename $(dirname "${GIT_REMOTE_OR_ORIGIN_URL//://}"))/$(basename "${GIT_REMOTE_OR_ORIGIN_URL}" .git) # editorconfig-checker-disable-line

GITHUB_SERVER_URL=${GITHUB_SERVER_URL:-https://github.com}
GITHUB_SERVER_URL_DOMAIN=$(basename "${GITHUB_SERVER_URL}")
# END sh/git.inc.sh
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/env.inc.sh
# BEGIN sh/env.inc.sh
#!/usr/bin/env bash
#!/usr/bin/env zsh

[[ -n "${YP_DIR:-}" ]] || {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"
        # >&2 echo YP_DIR=$YP_DIR
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2296
        YP_DIR="$(cd "$(dirname ${(%):-%x})/.." >/dev/null && pwd)"
    else
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
        exit 1
    fi
}


# ------------------------------------------------------------------------------
# source ${YP_DIR}/bin/yp-env "$@"
# BEGIN bin/yp-env "$@"
#!/usr/bin/env bash
#!/usr/bin/env zsh

if [[ -n "${BASH_VERSION:-}" ]]; then
    true
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    true
else
    >&2 echo "yp-env has been loaded in an unsupported shell ${SHELL:-} ."
    return 1
fi

function yp::stacktrace_file() {
    # see https://unix.stackexchange.com/a/453170/61053
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "${BASH_SOURCE[1]}"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2154
        echo "${funcfiletrace[1]%:*}"
    else
        echo "?file?"
    fi
}

function yp::stacktrace_line() {
    # see https://unix.stackexchange.com/a/453170/61053
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "${FUNCNAME[1]}"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "${funcfiletrace[1]##*:}"
    else
        echo "?line?"
    fi
}

function yp::stacktrace_func() {
    # see https://unix.stackexchange.com/a/453170/61053
    if [[ -n "${BASH_VERSION:-}" ]]; then
        echo "${FUNCNAME[1]}"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2154
        echo "${funcstack[2]}"
    else
        echo "?func?"
    fi
}

function yp::stacktrace() {
    echo "$(yp::stacktrace_file):$(yp::stacktrace_line) $(yp::stacktrace_func)"
}

function yp::executed() {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        for f in "${FUNCNAME[@]}"; do
            case "${f}" in
                main)
                    return 0
                    ;;
                source)
                    return 1
                    ;;
                *)
                    ;;
            esac
        done
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2154
        for f in "${funcstack[@]}"; do
            if [[ "${f}" =~ / ]]; then
                return 1
            fi
        done
        return 0
    else
        exit 1
    fi
}

function yp::sourced() {
    yp::executed || return 0
    return 1
}

function yp::env() {
    source ${YP_ENV:-${YP_DIR}/bin/yp-env}
}

function yp::env_force() {
    source ${YP_ENV:-${YP_DIR}/bin/yp-env} --force
}

# PATH FUNCTIONS ---------------------------------------------------------------

function yp::path() {
    export PATH="$1"
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
    hash -r
}

function yp::path_prepend() {
    echo ":${PATH}:" | grep -q ":$1:" || yp::path "$1:${PATH}"
}

function yp::path_prepend_after() {
    if echo ":${PATH}:" | grep -q ":$2:"; then
        yp::path "$(echo "${PATH}" | sed "s/:$2:/:$2:$1:/")"
    else
        yp::path_prepend "$1"
    fi
}

function yp::path_append() {
    echo ":${PATH}:" | grep -q ":$1:" || yp::path "${PATH}:$1"
}

function yp::path_append_before() {
    if echo ":${PATH}:" | grep -q ":$2:"; then
        yp::path "$(echo "${PATH}" | sed "s/:$2:/:$1:$2:/")"
    else
        yp::path_append "$1"
    fi
}

# SMART NVM INSTALL ------------------------------------------------------------

# nvm install --reinstall-packages-from=current, including npm
function yp::nvm_install() {
    local NODE=$(command -v node 2>/dev/null || true)
    local NODE_VSN="$(${NODE:-true} --version)"
    local NPM=$(command -v npm 2>/dev/null || true)
    local NPM_VSN="$(${NPM:-npm} --version)"

    [[ "$(nvm which current)" = "${NODE}" ]] || {
        # defensive, because I can't see a simple way to assign the above variables via 'nvm exec'
        >&2 echo "Expected NODE=${NODE} to be the same as 'nvm which current' $(nvm which current) ."
        return 1
    }

    local NODE_VSN_NVM="$(nvm version current)"

    [[ -n "${NODE}" ]] || {
        >&2 echo "No current node detected. Falling back to vanilla 'nvm install'."
        nvm install "$@"
        return 0
    }
    >&2 echo "Current NODE=${NODE} NODE_VSN=${NODE_VSN} NODE_VSN_NVM=${NODE_VSN_NVM} ."
    >&2 echo "Current NPM=${NPM} NPM_VSN=${NPM_VSN} ."
    nvm install "$@" --reinstall-package-from=${NODE_VSN_NVM}
    hash -r
    >&2 echo "Post-nvm NODE=$(command -v node 2>/dev/null || true) NODE_VSN=$(node --version) ."
    >&2 echo "Post-nvm NPM=$(command -v npm 2>/dev/null || true) NPM_VSN=$(npm --version) ."

    [[ "$(npm --version)" = "${NPM_VSN}" ]] || {
        npm install --silent -g npm@${NPM_VSN}
        hash -r
        >&2 echo "Post-npm NPM=$(command -v npm 2>/dev/null || true) NPM_VSN=$(npm --version) ."
    }
}

# SMART MAKE -------------------------------------------------------------------

# NOTE caveat: it doesn't work properly if 'make' is already an alias|function
# shellcheck disable=SC2034
typeset -f make >/dev/null || function make() {
    # NOTE zsh would output "make is /path/to/make"
    local MAKE_COMMAND=$(type -a -p make | head -1 | sed "s|^make is ||")
    case "$1" in
        --help|--version)
            ${MAKE_COMMAND} "$@"
            return $?
            ;;
        *)
            ;;
    esac
    if [[ -z "${YP_MAKE_COMMAND:-}" ]] && [[ -x make.sh ]]; then
        [[ -f make.sh.successful ]] || {
            >&2 echo "$(date +"%H:%M:%S")" "[INFO] Running    ${PWD}/make.sh $*"
            >&2 echo "                instead of ${MAKE_COMMAND} $*"
        }
        YP_MAKE_COMMAND=${MAKE_COMMAND} ./make.sh "$@"
        local EXIT_STATUS=$?
        # á la Ubuntu's ~/.sudo_as_admin_successful
        [[ ${EXIT_STATUS} -ne 0 ]] || touch make.sh.successful
        return ${EXIT_STATUS}
    fi
    ${MAKE_COMMAND} "$@"
}

# for when you want to skip ./make.sh
# NOTE caveat: it doesn't work properly if 'make' is already an alias|function
# shellcheck disable=SC2034
typeset -f make.bak >/dev/null || function make.bak() {
    # NOTE zsh would output "make is /path/to/make"
    local MAKE_COMMAND=$(type -a -p make | head -1 | sed "s|^make is ||")
    ${MAKE_COMMAND} "$@"
}

# MAIN -------------------------------------------------------------------------

yp::sourced || set -euo pipefail

YP_ENV_DIR="$(cd "$(dirname "$(yp::stacktrace_file)")/.." >/dev/null && pwd)"

# document exports
# NOTE exported variables need to be in sync with build.mk/core.common.mk:9
YP_ENV_EXPORTS=(
    HOMEBREW_PREFIX
    INFOPATH
    MANPATH
    NVM_DIR
    PATH
    YP_ENV
)

function yp-env-report() {
    yp::executed || {
        export "${YP_ENV_EXPORTS[@]}"
        unset -f yp-env-report
        unset YP_ENV_DIR
        unset YP_ENV_EXPORTS
        return 0
    }

    if [[ $# -eq 1 ]]; then
        eval "echo \${$1}"
    elif [[ $# -gt 1 ]]; then
        while [[ $# -gt 0 ]]; do
            eval "echo $1=\${$1}"
            shift
        done
    else
        for VAR in "${YP_ENV_EXPORTS[@]}"; do
            eval "echo ${VAR}=\${${VAR}:-}"
        done
    fi
}

[[ "${1:-}" != "--force" ]] || {
    unset YP_ENV
    shift
}

[[ "${YP_ENV:-}" != "${YP_ENV_DIR/bin/yp-env}" ]] || {
    if yp::sourced; then
        yp-env-report "$@" || return 1
        return 0
    else
        yp-env-report "$@"
        echo exit 0
    fi
}

hash -r # see https://github.com/Homebrew/brew/issues/5013
export YP_ENV=${YP_ENV_DIR}/bin/yp-env

[[ -z "${HOMEBREW_PREFIX:-}" ]] || [[ -f "${HOMEBREW_PREFIX:-}/bin/brew" ]] || {
    unset HOMEBREW_PREFIX
    unset HOMEBREW_CELLAR
    unset HOMEBREW_REPOSITORY
    unset HOMEBREW_SHELLENV_PREFIX
}

[[ -n "${HOMEBREW_PREFIX:-}" ]] || if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    # linux with sudo
    export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
elif [[ -x ${HOME}/.linuxbrew/bin/brew ]]; then
    # linux without sudo
    export HOMEBREW_PREFIX=${HOME}/.linuxbrew
elif [[ -x /usr/local/bin/brew ]]; then
    # macos
    export HOMEBREW_PREFIX=/usr/local
elif [[ -x /opt/homebrew/bin/brew ]]; then
    # macos m1
    export HOMEBREW_PREFIX=/opt/homebrew
elif command -v brew >/dev/null 2>&1; then
    # misc
    export HOMEBREW_PREFIX=$(brew --prefix)
fi

# remove homebrew (linuxbrew) from PATH which is appended, not prepended (default homebrew behaviour)
# see https://github.com/actions/virtual-environments/pull/789
[[ "${GITHUB_ACTIONS:-}" != "true" ]] || [[ "${RUNNER_OS:-}" != "Linux" ]] || {
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/bin:|:|" | sed "s|::|:|")
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/sbin:|:|" | sed "s|::|:|")
    yp::path "${PATH}"
}

# jq becomes always available
# NOTE if needed to bypass system's jq, call yp-jq
yp::path_append ${YP_ENV_DIR}/bin/.jq

# jd becomes always available
# NOTE if needed to bypass system's jd, call yp-jd
yp::path_append ${YP_ENV_DIR}/bin/.jd

# nanoseconds becomes always available
# NOTE if needed to bypass system's nanoseconds, call yp-nanoseconds
yp::path_append ${YP_ENV_DIR}/bin/.nanoseconds

# yq becomes always available
# NOTE if needed to bypass system's yq, call yp-yq
yp::path_append ${YP_ENV_DIR}/bin/.yq

yp::path_prepend /usr/local/sbin
yp::path_prepend /usr/local/bin
yp::path_prepend ${HOME}/.local/sbin
yp::path_prepend ${HOME}/.local/bin

[[ -n "${NVM_DIR:-}" ]] || export NVM_DIR=${HOME}/.nvm

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    # 'brew shellenv' duplicates items in PATH variables
    eval "$(HOMEBREW_SHELLENV_PREFIX="" ${HOMEBREW_PREFIX}/bin/brew shellenv | grep -v \
        -e "^export PATH=" \
        -e "^export MANPATH=" \
        -e "^export INFOPATH=")"

    yp::path_prepend ${HOMEBREW_PREFIX}/sbin
    yp::path_prepend ${HOMEBREW_PREFIX}/bin

    # yp_manpath_prepend ${HOMEBREW_PREFIX}/share/man
    HOMEBREW_MANPATH=${HOMEBREW_PREFIX}/share/man
    echo ":${MANPATH:-}:" | grep -q ":${HOMEBREW_MANPATH}:" || export MANPATH=${HOMEBREW_MANPATH}:${MANPATH:-}
    export MANPATH=$(echo "${MANPATH}" | sed "s|^:||" | sed "s|:$||")

    # yp_infopath_prepend ${HOMEBREW_PREFIX}/share/info
    HOMEBREW_INFOPATH=${HOMEBREW_PREFIX}/share/info
    echo ":${INFOPATH:-}:" | grep -q ":${HOMEBREW_INFOPATH}:" || export INFOPATH=${HOMEBREW_INFOPATH}:${INFOPATH:-}
    export INFOPATH=$(echo "${INFOPATH}" | sed "s|^:||" | sed "s|:$||")

    for f in coreutils findutils gawk gnu-sed gnu-tar gnu-time gnu-which grep gzip make; do
        yp::path_prepend ${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin
    done
    for f in curl gnu-getopt openssl@3 unzip zip; do
        yp::path_prepend ${HOMEBREW_PREFIX}/opt/${f}/bin
    done
    unset f

    # command is defined and is a function (no path)
    [[ "$(command -v nvm 2>&1 || true)" = "nvm" ]] || {
        NOUNSET_STATE="$(set +o | grep nounset)"
        set +u
        # using a less exact call because 'brew --prefix nvm' is very very slow
        # NVM_INSTALLATION_DIR=$(brew --prefix nvm 2>/dev/null || true)
        NVM_INSTALLATION_DIR=${HOMEBREW_PREFIX}/opt/nvm
        # shellcheck disable=SC1091
        [[ ! -r ${NVM_INSTALLATION_DIR}/nvm.sh ]] || source ${NVM_INSTALLATION_DIR}/nvm.sh --no-use
        unset NVM_INSTALLATION_DIR
        eval "${NOUNSET_STATE}"
        unset NOUNSET_STATE
    }

    # command is defined and is a function (no path)
    [[ "$(command -v asdf 2>&1 || true)" = "asdf" ]] || [[ -n "${ASDF_DIR:-}" ]] || {
        NOUNSET_STATE="$(set +o | grep nounset)"
        set +u
        # using a less exact call because 'brew --prefix asdf' is very very slow
        # ASDF_INSTALLATION_DIR=$(brew --prefix asdf 2>/dev/null || true)
        ASDF_INSTALLATION_DIR=${HOMEBREW_PREFIX}/opt/asdf
        # shellcheck disable=SC1091
        [[ ! -r ${ASDF_INSTALLATION_DIR}/libexec/asdf.sh ]] || source ${ASDF_INSTALLATION_DIR}/libexec/asdf.sh
        eval "${NOUNSET_STATE}"
        unset NOUNSET_STATE
    }
fi

[[ -z "${ASDF_DIR:-}" ]] || {
    # user a hardcoded value for performance
    # yp::path_prepend "$(${YP_ENV_DIR}/bin/asdf-get-asdf-bin)"
    # yp::path_prepend "$(${YP_ENV_DIR}/bin/asdf-get-asdf-user-shims)"
    yp::path_prepend "${ASDF_DIR}/bin"
    yp::path_prepend "${ASDF_DATA_DIR:-${HOME}/.asdf}/shims"
}

[[ -z "${NVM_BIN:-}" ]] || {
    # user a hardcoded value for performance
    # yp::path_prepend "$(${YP_ENV_DIR}/bin/nvm-get-nvm-bin)"
    yp::path_prepend "${NVM_BIN}"
}

yp-env-report "$@"
# END bin/yp-env "$@"
# ------------------------------------------------------------------------------

# END sh/env.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# source ${YP_DIR}/sh/exe.inc.sh
# BEGIN sh/exe.inc.sh
#!/usr/bin/env bash
set -euo pipefail

# ECHO -------------------------------------------------------------------------

YP_CI_ECHO_BENCHMARK=${YP_CI_ECHO_BENCHMARK:-/dev/null}
export YP_CI_ECHO="${YP_DIR}/bin/ci-echo --benchmark ${YP_CI_ECHO_BENCHMARK}"

function echo_do() {
    ${YP_CI_ECHO} -- "[DO  ]" "$@"
}

# shellcheck disable=SC2120
function echo_done() {
    ${YP_CI_ECHO} -- "[DONE]" "$@"
}

function echo_indent() {
    ${YP_CI_ECHO} -- "      " "$@"
}

function echo_next() {
    ${YP_CI_ECHO} -- "[NEXT]" "$@"
}

function echo_q() {
    ${YP_CI_ECHO} -- "[Q   ]" "$@"
}

function echo_skip() {
    ${YP_CI_ECHO} -- "[SKIP]" "$@"
}

# ECHO -------------------------------------------------------------------------

function echo_err() {
    ${YP_CI_ECHO} -- "[ERR ]" "$@"
}

function echo_info() {
    ${YP_CI_ECHO} -- "[INFO]" "$@"
}

function echo_warn() {
    ${YP_CI_ECHO} -- "[WARN]" "$@"
}

# SHELL ------------------------------------------------------------------------

function sh_script_usage() {
    grep "^##" "${0}" | cut -c 4- | if command -v envsubst >/dev/null 2>&1; then envsubst; else cat; fi
    # return 1
    exit 1
}

function sh_script_version() {
    grep "^#-" "${0}" | cut -c 4- | if command -v envsubst >/dev/null 2>&1; then envsubst; else cat; fi
    # return 1
    exit 1
}

function sh_shellopts() {
    # usage: OLDOPTS="$(sh_shellopts)"; ...; sh_shellopts_restore "${OLDOPTS}"

    # see https://unix.stackexchange.com/a/383581/61053
    # see https://unix.stackexchange.com/a/476710/61053
    local OLDOPTS="$(set +o)"
    # bash resets errexit inside sub-shells like $(set +o) above
    [[ ! -o errexit ]] || OLDOPTS="${OLDOPTS}; set -e"
    if [[ -n "${BASH_VERSION:-}" ]]; then
        # bash-specific options
        OLDOPTS="${OLDOPTS}; $(shopt -p)"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # zsh-specific options
        OLDOPTS="${OLDOPTS}; setopt $(setopt); unsetopt $(unsetopt)"
    fi
    return "${OLDOPTS}"
}

function sh_shellopts_restore() {
    set +vx
    eval "$1"
}

# EXE --------------------------------------------------------------------------

function exe() {
    local PS_MARKER="\$"
    [[ "${EUID}" != "0" ]] || PS_MARKER="#"
    >&2 echo "$(pwd)${PS_MARKER} $*"
    "$@"
}

function exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXPECTED_STDOUT="$1"
    shift

    local EXECUTABLE="$(echo "${CMD}" | cut -d" " -f1)"
    local EXECUTABLE_TYPE="$(type -t ${EXECUTABLE} || echo "undefined")"
    local CMD_STDOUT="command not found: ${EXECUTABLE}"
    local CMD_STDERR="$(mktemp -t yplatform.XXXXXXXXXX)"
    if [[ "${EXECUTABLE_TYPE}" != "undefined" ]]; then
        CMD_STDOUT="$(eval "${CMD}" 2>${CMD_STDERR} || true)"
    fi

    if echo "${CMD_STDOUT}" | grep -q "${EXPECTED_STDOUT}"; then
        echo_info "Command '${CMD}' with stdout '${CMD_STDOUT}' matches '${EXPECTED_STDOUT}'."
    else
        echo_err "Command '${CMD}' with stdout '${CMD_STDOUT}' failed to match '${EXPECTED_STDOUT}'."
        echo_info "Command stderr: $(cat ${CMD_STDERR})"
        echo_info "Command's executable info:"
        >&2 debug_exe "${EXECUTABLE}"
        rm -f ${CMD_STDERR}
        return 1
    fi
    rm -f ${CMD_STDERR}
}

function if_exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXPECTED_STDOUT="$1"
    shift

    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}"; then
        "$@"
        hash -r
        >&2 debug_exe "${EXECUTABLE}"
        if exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}"; then
            return 1
        fi
    else
        >&2 echo_skip "$@"
    fi
}

function unless_exe_and_grep_q() {
    local CMD="$1"
    shift
    local EXPECTED_STDOUT="$1"
    shift

    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}"; then
        >&2 echo_skip "$@"
    else
        "$@"
        hash -r
        >&2 debug_exe "${EXECUTABLE}"
        exe_and_grep_q "${CMD}" "${EXPECTED_STDOUT}"
    fi
}

function debug_exe() {
    local EXECUTABLE="$1"
    local EXECUTABLE_TYPE="$(type -t ${EXECUTABLE} || echo "undefined")"
    if [[ "${EXECUTABLE_TYPE}" = "file" ]]; then
        type -a ${EXECUTABLE}
        type -a -p ${EXECUTABLE} | while read -r EXECUTABLE_PATH; do \
            ls -l "${EXECUTABLE_PATH}"
        done
        type ${EXECUTABLE} || true
    else
        echo "PATH=${PATH}"
        echo "${EXECUTABLE} is ${EXECUTABLE_TYPE}."
    fi
}

# PRINTENV ---------------------------------------------------------------------

# list all shell variables' names, not just exported variables
function printenv_all_names() {
    compgen -A variable
}

# list shell variables, not just exported variables
function printenv_all() {
    local VARS="$*"
    [[ $# -ne 0 ]] || VARS="$(printenv_all_names | grep -v "^VARS$")"

    # not sure why, but printenv_all_names catches "undefined" vars e.g. BASH_ALIASES
    local NOUNSET_STATE="$(set +o | grep nounset)"
    set +u
    for VAR in ${VARS}; do
        echo "${VAR}=${!VAR}"
    done
    eval "${NOUNSET_STATE}"
    unset NOUNSET_STATE
}

# MISC -------------------------------------------------------------------------

# - use with: cmd1 | cmd2 || exit_allow_sigpipe
# - use with: cmd1 | cmd2 || exit_allow_sigpipe "$?"
# - use with: cmd1 | cmd2 || exit_allow_sigpipe "${PIPESTATUS[@]}"
# - use with: cmd1 | cmd2 || exit_allow_sigpipe "$?" "${PIPESTATUS[@]}"
function exit_allow_sigpipe() {
    local EXIT_STATUS=$?
    [[ $# -ne 0 ]] || set -- "${EXIT_STATUS}"
    for EXIT_STATUS in "$@"; do
        [[ "${EXIT_STATUS}" = "0" ]] || \
            [[ "${EXIT_STATUS}" = "141" ]] || \
            return ${EXIT_STATUS}
    done
    return 0
}

function prompt_q_to_continue() {
    local Q="${1:-Are you sure you want to continue?}"
    local CANCEL_KEY="${2:-Ctrl-C}"
    echo_q "${Q}"
    echo_indent "Press ENTER to Continue."
    echo_indent "Press ${CANCEL_KEY} to Cancel."
    if [[ "${CI:-}" = "true" ]]; then
        echo_info "CI pressed ENTER."
        return 0
    fi
    read -r -p "" -n1
    echo
    [[ "${REPLY}" != "${CANCEL_KEY}" ]]
}

ANY_PYTHON=
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python3 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python2 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-ANY_PYTHON_NOT_FOUND}
# END sh/exe.inc.sh
# ------------------------------------------------------------------------------
