#!/usr/bin/env bash
set -euo pipefail

[[ -n "${SUPPORT_FIRECLOUD_DIR:-}" ]] || \
    export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC2128
if [ -z "${BASH_VERSINFO}" ] || [ -z "${BASH_VERSINFO[0]}" ] || [ ${BASH_VERSINFO[0]} -lt 4 ]; then
    echo >&2 "[WARN] Your Bash version is ${BASH_VERSINFO[0]}. ${0} may require >= 4.";
fi

source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/util/exe.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/magic.inc.sh
if command -v apt-get >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/apt.inc.sh
elif command -v yum >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/yum.inc.sh
elif command -v pacman >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/pacman.inc.sh
elif command -v apk >/dev/null 2>&1; then
    source ${SUPPORT_FIRECLOUD_DIR}/sh/package-managers/apk.inc.sh
fi
