#!/usr/bin/env bash

function sf_ci_run_notifications_slack() {
    [[ -n "${SLACK_WEBHOOK:-}" ]] || return 0

    echo "SF_CI_STATUS=${SF_CI_STATUS:-}"
    case "${SF_CI_STATUS:-}" in
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
        "Build ${SF_CI_JOB_ID} (${SF_CI_GIT_HASH}) of \
        ${SF_CI_REPO_SLUG}@${SF_CI_GIT_BRANCH:-${SF_CI_GIT_TAG:-${SF_CI_GIT_HASH}}} \
        by $(git log -1 --pretty=format:%cn) \
        completed with status '${SF_CI_STATUS}'."
}

function sf_ci_run_notifications() {
    sf_ci_run_notifications_slack
}
