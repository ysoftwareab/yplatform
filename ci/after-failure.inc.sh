#!/usr/bin/env bash
set -euo pipefail

function yp_ci_run_after_failure_force_close_ci_echo_groups() {
    # TODO leaking implementation detail
    local INSIDE_AFTER_FAILURE_GROUP=true
    for GROUP_MARKER in $(ls -t /tmp/ci-echo-group-* 2>/dev/null || true); do
        >&2 echo
        >&2 echo -n "Found ${GROUP_MARKER}: "
        >&2 cat "${GROUP_MARKER}" || echo
        sudo chown $(id -u):$(id -g) "${GROUP_MARKER}" || true
        [[ "${INSIDE_AFTER_FAILURE_GROUP}" = "true" ]] || {
            YP_CI_STATUS=failure echo_done
            continue
        }
        [[ "$(cat "${GROUP_MARKER}" | sed -n "2,2 p")" != "after_failure" ]] || INSIDE_AFTER_FAILURE_GROUP=false
        echo_skip "[DONE] $(cat "${GROUP_MARKER}" | sed -n "2,2 p")"
        local GROUP_MARKER_FILENAME=${GROUP_MARKER##*/}
        mv "${GROUP_MARKER}" "/tmp/after-failure-${GROUP_MARKER_FILENAME}"
    done
    for GROUP_MARKER in $(ls -t /tmp/after-failure-ci-echo-group-* 2>/dev/null || true); do
        local GROUP_MARKER_FILENAME=${GROUP_MARKER##*/}
        mv "${GROUP_MARKER}" "/tmp/${GROUP_MARKER_FILENAME#"after-failure-"}"
    done
}

function yp_ci_run_after_failure() {
    yp_ci_run_after_failure_force_close_ci_echo_groups
}
