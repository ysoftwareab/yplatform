#!/usr/bin/env bash
# shellcheck disable=SC2034
true

source ${SUPPORT_FIRECLOUD_DIR}/sh/ci-home.inc.sh

for SF_CI_ENV in ${SUPPORT_FIRECLOUD_DIR}/sh/env-ci/*.inc.sh; do
    source ${SF_CI_ENV}
done
unset SF_CI_ENV

for SF_CI_ENV_FUN in $(declare -F | grep --only-matching "\bsf_ci_env_.*"); do
    "${SF_CI_ENV_FUN}"
done
unset SF_CI_ENV_FUN
