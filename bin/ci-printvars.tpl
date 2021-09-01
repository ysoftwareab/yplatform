#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

cat <<EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
source \${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

#- ci-printvars 1.0
## Usage: ci-printvars
## Print detected-CI-platform's environment variables.
##
##   --unknown      Print only unknown environment variables.
##
##   -h, --help     Display this help and exit
##   -v, --version  Output version information and exit

if { getopt --test >/dev/null 2>&1 && false; } || [[ "\$?" = "4" ]] || false; then
    ARGS=\$(getopt -o hvu -l help,version,unknown -n \$(basename \${BASH_SOURCE[0]}) -- "\$@") || sh_script_usage
    eval set -- "\${ARGS}"
fi

UNKNOWN=false

while [[ \$# -gt 0 ]]; do
    case "\$1" in
        --unknown)
            UNKNOWN=true
            shift
            ;;
        -h|--help)
            sh_script_usage
            ;;
        -v|--version)
            sh_script_version
            ;;
        --)
            shift
            break
            ;;
        -*)
            sh_script_usage
            ;;
        *)
            break
            ;;
    esac
done
[[ \$# -eq 0 ]] || sh_script_usage

EOF

SF_CI_PRINTVAR_PLATFORMS=
for SF_CI_ENV_INC_SH in "${SUPPORT_FIRECLOUD_DIR}"/ci/env/*; do
    SF_CI_PRINTVAR_PLATFORMS="${SF_CI_PRINTVAR_PLATFORMS} $(basename ${SF_CI_ENV_INC_SH} .inc.sh)"
    cat ${SF_CI_ENV_INC_SH}
done

cat <<EOF

for SF_CI_PRINTVAR_PLATFORM in ${SF_CI_PRINTVAR_PLATFORMS}; do
    "sf_ci_env_\${SF_CI_PRINTVAR_PLATFORM}"
done

[[ "\${UNKNOWN}" != "true" ]] || {
    "sf_ci_printvars_\${SF_CI_PLATFORM}" | \
        sed "s/=.*//g" | \
        grep -Fvxf <("sf_ci_known_env_\${SF_CI_PLATFORM}") | \
        ${SUPPORT_FIRECLOUD_DIR}/bin/ifne --fail
    exit 0
}

[[ -n "\${SF_CI_PLATFORM:-}" ]] || {
    echo_warn "No CI platform detected."
    exit 0
}
"sf_ci_printvars_\${SF_CI_PLATFORM}"

EOF
