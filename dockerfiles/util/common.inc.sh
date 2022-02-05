#!/usr/bin/env bash
set -euo pipefail

[[ -n "${YP_DIR:-}" ]] || \
    export YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null && pwd)"

# shellcheck disable=SC2128
if [[ -z "${BASH_VERSINFO}" ]] || [[ -z "${BASH_VERSINFO[0]}" ]] || [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    >&2 echo "$(date +"%H:%M:%S")" "[WARN] Your Bash version is ${BASH_VERSINFO[0]}. ${0} may require >= 4.";
fi

source ${YP_DIR}/sh/core.inc.sh
source ${YP_DIR}/sh/sudo.inc.sh
source ${YP_DIR}/sh/os.inc.sh
source ${YP_DIR}/sh/os-release.inc.sh
source ${YP_DIR}/sh/git.inc.sh

source ${YP_DIR}/dockerfiles/util/env.inc.sh
source ${YP_DIR}/sh/exe.inc.sh

source ${YP_DIR}/sh/package-managers/brew.inc.sh
source ${YP_DIR}/sh/package-managers/magic.inc.sh
if command -v apt-get >/dev/null 2>&1; then
    source ${YP_DIR}/sh/package-managers/apt.inc.sh
elif command -v yum >/dev/null 2>&1; then
    source ${YP_DIR}/sh/package-managers/yum.inc.sh
elif command -v pacman >/dev/null 2>&1; then
    source ${YP_DIR}/sh/package-managers/pacman.inc.sh
elif command -v apk >/dev/null 2>&1; then
    source ${YP_DIR}/sh/package-managers/apk.inc.sh
fi
