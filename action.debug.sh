#!/usr/bin/env bash
set -euo pipefail

[[ "${INPUT_XTRACE}" != "true" ]] || set -x

>&2 echo "$(date +"%H:%M:%S") [INFO] Printing debug info..."
echo ::group::github event
cat "${GITHUB_EVENT_PATH}"
echo ::endgroup::

echo ::group::printenv
printenv
echo ::endgroup::

# FIXME https://github.com/actions/runner/issues/863
echo ::group::HOME
source "${GITHUB_ACTION_PATH}/sh/core-ci-home.inc.sh"
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
