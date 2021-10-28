#!/usr/bin/env bash
set -euo pipefail

function sf_ci_run_all() {
    local YP_CI_PHASES="$(cat <<-EOF
before_install
install
before_script
script
EOF
)"

    for f in ${YP_CI_PHASES}; do
        sf_ci_run ${f};
    done
}

# call this function from wherever you want to start a debug shell
function sf_ci_debug() {
    echo_info "Starting a debug shell via ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell."
    echo_info "Run 'touch ${GIT_ROOT}/.tmate.continue', if you want the workflow to continue."
    echo_info "Workflow will be cancelled otherwise."

    [[ -n ${YP_TMATE_AUTH:-} ]] || [[ ! -f ${GIT_ROOT}/.tmate.authorized_keys ]] || {
        YP_TMATE_AUTH=${GIT_ROOT}/.tmate.authorized_keys
    }

    [[ -n ${YP_TMATE_AUTH:-} ]] || [[ "${YP_CI_PLATFORM:-}" != "github" ]] || {
        echo_info "Tmate session will be restricted to GITHUB_ACTOR=${GITHUB_ACTOR}."
        # default to github actor's public ssh keys
        YP_TMATE_AUTH=$(mktemp -t firecloud.XXXXXXXXXX)
        exe curl -qfsSL \
            -H "accept: application/vnd.github.v3+json" \
            -H "authorization: token ${YP_GH_TOKEN_DEPLOY}" \
            https://api.github.com/users/${GITHUB_ACTOR}/keys | \
            jq -r ".[].key" > ${YP_TMATE_AUTH}
    }

    if [[ "${YP_TMATE_AUTH:-}" = "none" ]]; then
        echo_warn "Tmate session will be unrestricted due to YP_TMATE_AUTH=${YP_TMATE_AUTH}."
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    elif [[ "${YP_DOCKER:-}" = "true" ]]; then
        echo_warn "Tmate session will be unrestricted due to YP_DOCKER=${YP_DOCKER}."
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell
    elif [[ -n ${YP_TMATE_AUTH:-} ]]; then
        echo_info "Tmate session will be restricted to YP_TMATE_AUTH=${YP_TMATE_AUTH}."
        cat ${YP_TMATE_AUTH}
        ${SUPPORT_FIRECLOUD_DIR}/bin/tmate-shell ${YP_TMATE_AUTH}
    else
        echo_err "No YP_TMATE_AUTH defined. Refusing to start a tmate session open to the world."
        echo_info "Define YP_TMATE_AUTH=none if you really want to."
    fi
    # allow session to continue based on a file marker; exit by default
    if [[ -f ${GIT_ROOT}/.tmate.continue ]]; then
        rm ${GIT_ROOT}/.tmate.continue
    else
        exit 1
    fi
}
export -f sf_ci_debug

function sf_ci_debug_no_auth() {
    YP_TMATE_AUTH=none sf_ci_debug
}
export -f sf_ci_debug_no_auth
