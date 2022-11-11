#!/usr/bin/env bash
set -euo pipefail

[[ -n "${YP_DIR:-}" ]] || \
    export YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"

# shellcheck disable=SC2128
if [[ -z "${BASH_VERSINFO}" ]] || [[ -z "${BASH_VERSINFO[0]}" ]] || [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Your Bash version is ${BASH_VERSINFO[0]}. ${0} may require >= 4.";
fi


# ------------------------------------------------------------------------------
# BEGIN core.inc.sh
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
# END core.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# BEGIN sudo.inc.sh
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
# END sudo.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# BEGIN os.inc.sh
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
    -e "s|^x86\-64$|amd64|" \
)
ARCH_SHORT=$(echo "${ARCH}" | grep -q "64" && echo "x64" || echo "x86")
ARCH_BIT=$(echo "${ARCH}" | grep -q "64" && echo "64" || echo "32")

OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
# END os.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# BEGIN os-release.inc.sh
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
# END os-release.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# BEGIN git.inc.sh
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
GIT_REPO_HAS_UNTRACKED_FILES=$(git status --porcelain 2>/dev/null | grep -q -e "^\?\?" && \
    echo true || echo false)
GIT_REPO_HAS_CONFLICTS=$(git status --porcelain 2>/dev/null | grep -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
    echo true || echo false)
# END git.inc.sh
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# BEGIN env.inc.sh
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

source ${YP_DIR}/bin/yp-env "$@"
# END env.inc.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# BEGIN exe.inc.sh
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

function exit_allow_sigpipe() {
    local EXIT_STATUS=$?
    [[ ${EXIT_STATUS} -eq 141 ]] || exit ${EXIT_STATUS}
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
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python2 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-$(command -v -p python3 2>/dev/null || true)}
ANY_PYTHON=${ANY_PYTHON:-ANY_PYTHON_NOT_FOUND}
# END exe.inc.sh
# ------------------------------------------------------------------------------

