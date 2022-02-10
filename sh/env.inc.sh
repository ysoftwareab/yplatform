#!/usr/bin/env bash
#!/usr/bin/env zsh

[[ -n "${YP_DIR:-}" ]] || {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"
        # >&2 echo YP_DIR=$YP_DIR
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # shellcheck disable=SC2296
        YP_DIR="$(cd "$(dirname ${(%):-%x})/.." >/dev/null && pwd)"
    else
        >&2 echo "$(date +"%H:%M:%S")" "[ERR ] Unsupported shell or \$BASH_VERSION and \$ZSH_VERSION are undefined."
        exit 1
    fi
}

source ${YP_DIR}/bin/yp-env
