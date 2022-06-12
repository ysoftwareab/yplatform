#!/usr/bin/env bash
set -euo pipefail

# YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null && pwd)"

# detect CI platform
for YP_CI_ENV in ${YP_DIR}/ci/env/*.inc.sh; do
    source ${YP_CI_ENV}
done
unset YP_CI_ENV
for YP_CI_ENV_FUN in $(declare -F | grep --only-matching "\byp_ci_env_.*"); do
    "${YP_CI_ENV_FUN}"
    [[ -z "${YP_CI_PLATFORM:-}" ]] || break
done
unset YP_CI_ENV_FUN

[[ -z "${YP_CI_PLATFORM:-}" ]] || eval "export $(yp_ci_known_env_yp | tr "\n" " ")"
