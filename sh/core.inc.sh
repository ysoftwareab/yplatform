#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

# see https://www.shell-tips.com/bash/debug-script/
function on_error() {
    >&2 echo "The following BASH_COMMAND exited with status $1."
    >&2 echo "=${BASH_COMMAND}"
    >&2 echo "~$(eval echo "${BASH_COMMAND}")"
    # NOTE i=1 instead of i=0 to skip printing info about our 'on_error' function
    # see https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#index-BASH_005fLINENO
    for (( i=1; i<${#BASH_SOURCE[@]}; i++ )); do
        >&2 echo "${i}. ${BASH_SOURCE[${i}]}: line ${BASH_LINENO[${i}-1]}: ${FUNCNAME[${i}]}"
    done
    >&2 echo "---"
}
trap 'on_error $?' ERR
set -o errtrace -o functrace

[[ -n "${SUPPORT_FIRECLOUD_DIR:-}" ]] || \
    export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CI="${CI:-}"
[[ "${CI}" != "1" ]] || CI=true

V="${V:-${VERBOSE:-}}"
VERBOSE="${V}"
[[ "${VERBOSE}" != "1" ]] || VERBOSE=true

# [[ "${CI}" != "true" ]] || {
#     # VERBOSE=true
# }

if [[ -n "${VERBOSE}" ]]; then
    set -x
    if [[ "${VERBOSE}" != "true" ]]; then
        exec {BASH_XTRACEFD}> >(tee -a "${VERBOSE}" >&2)
        export BASH_XTRACEFD
    fi
fi

if printenv | grep -q "^SF_SUDO="; then
    # Don't change if already set.
    # NOTE 'test -v SF_SUDO' is only available in bash 4.2, but this script may run in bash 3+
    true
else
    SF_SUDO="$(which sudo 2>/dev/null || true)"
    if [[ -z "${SF_SUDO}" ]]; then
        if [[ "${EUID}" = "0" ]]; then
            # Root user doesn't need sudo.
            true
        else
            SF_SUDO=sf_nosudo
            # The user has exported SF_SUDO= or has no sudo installed.
            function sf_nosudo() {
                echo "[ERR ] sudo required, but not available for running the following command:"
                echo "       $*"
                echo "[Q   ] Run the command yourself as root, then continue."
                echo "       Press ENTER to Continue."
                echo "       Press Ctrl-C to Cancel."
                read -r -p ""
                echo
            }
            export -f sf_nosudo
        fi
    fi
    export SF_SUDO
fi

ARCH=$(uname -m)
ARCH_BIT=$(echo "${ARCH}" | grep -q "x86_64" && echo "64" || echo "32")
# FIXME should handle arm64 aarch64 others?! Same in build.mk/core.inc.mk/os.inc.mk
ARCH_SHORT=$(echo "${ARCH}" | grep -q "x86_64" && echo "x64" || echo "x86")
OS=$(uname | tr "[:upper:]" "[:lower:]")
OS_SHORT=$(echo "${OS}" | sed "s/^\([[:alpha:]]\{1,\}\).*/\1/g")
case ${OS_SHORT} in
    darwin)
        OS_RELEASE_VERSION_ID=$(sw_vers -productVersion)

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

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
GIT_BRANCH_SHORT=$(basename "${GIT_BRANCH}" 2>/dev/null || true)
GIT_HASH=$(git rev-parse HEAD 2>/dev/null || true)
GIT_HASH_SHORT=$(git rev-parse --short HEAD 2>/dev/null || true)
GIT_REMOTE=$(git config branch.${GIT_BRANCH}.remote 2>/dev/null || true)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
GIT_TAGS=$(git describe --exact-match --tags HEAD 2>/dev/null || true)

[[ "${CI}" != "true" ]] || source ${SUPPORT_FIRECLOUD_DIR}/sh/core-ci.inc.sh
