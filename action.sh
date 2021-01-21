#!/usr/bin/env bash

# FIXME https://github.com/actions/runner/issues/863
source "${GITHUB_ACTION_PATH}/sh/core-ci-home.inc.sh"

[[ "${INPUT_DEBUG}" != "true" ]] || {
    echo ::group::github event
    cat "${GITHUB_EVENT_PATH}"
    echo ::endgroup::

    echo ::group::printenv
    printenv
    echo ::endgroup::

    echo ::group::pwd
    pwd
    ls -la
    echo ::endgroup::

    echo ::group::action pwd
    (
        cd "${GITHUB_ACTION_PATH}"
        pwd
        ls -la
    )
    echo ::endgroup::
}

cd "${GITHUB_ACTION_PATH}"
${INPUT_COMMAND}
