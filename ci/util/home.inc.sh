#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

# HOME is always set incorrectly to /github/home, even in containers
# see https://github.com/actions/runner/issues/863
HOME_REAL=$(eval echo "~$(id -u -n)")
[[ "${HOME}" = "${HOME_REAL}" ]] || {
    >&2 echo "$(date +"%H:%M:%S") [WARN] \$HOME is overriden to ${HOME}."
    >&2 echo "$(date +"%H:%M:%S") [DO  ] Resetting \$HOME to ${HOME_REAL}..."

    TMP_ENV=$(mktemp -t yplatform.XXXXXXXXXX)
    TMP_ENV2=$(mktemp -t yplatform.XXXXXXXXXX)
    TMP_ENV_DIFF=$(mktemp -t yplatform.XXXXXXXXXX)
    SED_RANDOM="$$.${RANDOM}.$$"

    # store exported vars as singleline vars (easier to diff)
    {
        export -p | grep "^declare" | sed "s/^declare \-x //g" | sed "s/=.*//g" | sort -u | while read -r VAR; do
            echo -n "${VAR}="
            echo "${!VAR:-}" | \
                sed -e ":a" -e "N" -e "\$!ba" -e "s/\r/{{CRLF${RANDOM}CRLF}}/g" -e "s/\n/{{LF${RANDOM}LF}}/g"
        done
    } >>${TMP_ENV}

    export HOME="${HOME_REAL}"

    # NOTE ideally we would unset all current variables,
    # but we need to detect and retain those set in the CI configuration
    # e.g. not only GITHUB_*, but also any given in "env:" as part of a workflow
    # so instead we only overwrite current variables
    eval "$(env -i HOME="${HOME}" bash -l -i -c "export -p; export -pf" | grep -v "^declare -x \(SHLVL\)")"

    # store exported vars as singleline vars (easier to diff)
    {
        export -p | grep "^declare" | sed "s/^declare \-x //g" | sed "s/=.*//g" | sort -u | while read -r VAR; do
            echo -n "${VAR}="
            echo "${!VAR:-}" | \
                sed -e ":a" -e "N" -e "\$!ba" -e "s/\r/{{CRLF${RANDOM}CRLF}}/g" -e "s/\n/{{LF${RANDOM}LF}}/g"
        done
    } >>${TMP_ENV2}

    diff --unified=0 ${TMP_ENV} ${TMP_ENV2} >${TMP_ENV_DIFF} || true

    [[ ! -s "${TMP_ENV_DIFF}" ]] || {
        >&2 echo "$(date +"%H:%M:%S") [INFO] Following environment variables have changed after resetting \$HOME:"
        cat "${TMP_ENV_DIFF}" | tail -n+3 | grep "^[+-]" >&2

        # NOTE can't use YP_CI_PLATFORM because this script is sourced before
        # [[ "${YP_CI_PLATFORM:-}" != "github" ]] || {
        [[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
            >&2 echo "$(date +"%H:%M:%S") [INFO] Updating \$GITHUB_ENV with the new environment variables..."
            touch ${GITHUB_ENV} || ${YP_SUDO:-sudo} touch ${GITHUB_ENV}
            {
                cat "${TMP_ENV_DIFF}" | tail -n+4 | grep "^+" | sed "s/^+//g" | sed "s/=.*//g" | while read -r VAR; do
                    # write only HOME variable in github env, fearing we do more harm otherwise
                    [[ "${VAR}" = "HOME" ]] || continue

                    # skip YP_DEV_INC_SH or else sh/dev.inc.sh will not be sourced on login shells
                    # [[ "${VAR}" != "YP_DEV_INC_SH" ]] || continue

                    echo -n "${VAR}"
                    case "${!VAR:-}" in
                        *$'\r'*|*$'\n'*)
                            echo "<<EOF"
                            echo "${!VAR:-}"
                            echo "EOF"
                            ;;
                        *)
                            echo "=${!VAR:-}"
                            ;;
                    esac
                done
            } | exe ${YP_SUDO:-sudo} tee -a ${GITHUB_ENV}
        }
    }

    rm -f ${TMP_ENV}
    rm -f ${TMP_ENV2}
    rm -f ${TMP_ENV_DIFF}

    >&2 echo "$(date +"%H:%M:%S") [DONE]"
}
unset HOME_REAL
