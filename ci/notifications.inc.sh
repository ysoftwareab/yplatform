#!/usr/bin/env bash

function sf_ci_run_notifications_slack() {
    [[ -n "${SLACK_WEBHOOK:-}" ]] || return 0

    echo "CI_STATUS=${CI_STATUS:-}"
    case "${CI_STATUS:-}" in
        failure|Failure)
            true
            ;;
        *)
            return 0
            ;;
    esac

    local FEMALE_OR_MALE=female
    test $(( ${RANDOM} % 2 )) -eq 0 || FEMALE_OR_MALE=male
    exe ${SUPPORT_FIRECLOUD_DIR}/bin/slack-echo \
        --from "$(git config user.name)" \
        --icon ":${FEMALE_OR_MALE}-technologist:" \
        "Build ${CI_JOB_ID} (${GIT_HASH_SHORT}) of ${CI_REPO_SLUG}@${GIT_BRANCH:-${CI_TAG}} \
        by $(git log -1 --pretty=format:%cn) \
        completed with status '${CI_STATUS}'."
}

function sf_ci_run_notifications() {
    sf_ci_run_notifications_slack
}
