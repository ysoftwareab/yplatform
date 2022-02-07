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
