#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

cat <<EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

#- ci-printvars 1.0
## Usage: ci-printvars
## Print SF_CI_* vars in a platform-agnostic way.

SUPPORT_FIRECLOUD_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"

EOF

SF_CI_PRINTVAR_PLATFORMS=
for SF_CI_ENV_INC_SH in "${SUPPORT_FIRECLOUD_DIR}"/ci/env/*; do
    SF_CI_PRINTVAR_PLATFORMS="${SF_CI_PRINTVAR_PLATFORMS} $(basename ${SF_CI_ENV_INC_SH} .inc.sh)"
    cat ${SF_CI_ENV_INC_SH}
done

cat <<EOF
for SF_CI_PRINTVAR_PLATFORM in ${SF_CI_PRINTVAR_PLATFORMS}; do
    eval "sf_ci_env_\${SF_CI_PRINTVAR_PLATFORM}"
done

# cannot use printenv because variables are not exported
# printenv | grep "^CI[_=]"
compgen -A variable | sort -u | grep -e "^CI\$" -e "^SF_CI_" | while read -r NO_XARGS_R; do
    [[ -n "\${NO_XARGS_R}" ]] || continue;
    echo "\${NO_XARGS_R}=\${!NO_XARGS_R}"
done
EOF
