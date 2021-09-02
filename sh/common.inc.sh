#!/usr/bin/env bash
set -euo pipefail

[[ -n "${SUPPORT_FIRECLOUD_DIR:-}" ]] || \
    export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC2128
if [[ -z "${BASH_VERSINFO}" ]] || [[ -z "${BASH_VERSINFO[0]}" ]] || [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo >&2 "[WARN] Your Bash version is ${BASH_VERSINFO[0]}. ${0} may require >= 4.";
fi

source ${SUPPORT_FIRECLOUD_DIR}/sh/core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/sudo.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/os.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/os-release.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/git.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/sh/env.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/exe.inc.sh
