#!/usr/bin/env bash
set -euo pipefail

function sf_ci_run_notifications_slack() {
    [[ -n "${SLACK_WEBHOOK:-}" ]] || return 0

    echo "YP_CI_STATUS=${YP_CI_STATUS:-}"
    case "${YP_CI_STATUS:-}" in
        failure|Failure)
            true
            ;;
        *)
            return 0
            ;;
    esac

    local FEMALE_OR_MALE=female
    [[ $(( ${RANDOM} % 2 )) -eq 0 ]] || FEMALE_OR_MALE=male
    exe ${SUPPORT_FIRECLOUD_DIR}/bin/slack-echo \
        --from "$(git config user.name)" \
        --icon ":${FEMALE_OR_MALE}-technologist:" \
        "Build ${YP_CI_JOB_ID} (${YP_CI_GIT_HASH}) of \
        ${YP_CI_REPO_SLUG}@${YP_CI_GIT_BRANCH:-${YP_CI_GIT_TAG:-${YP_CI_GIT_HASH}}} \
        by $(git log -1 --pretty=format:%cn) \
        completed with status '${YP_CI_STATUS}'."
}

function sf_ci_run_notifications() {
    sf_ci_run_notifications_slack
}
