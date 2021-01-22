#!/usr/bin/env bash

# FIXME https://github.com/actions/runner/issues/863
source "${GITHUB_ACTION_PATH}/sh/core-ci-home.inc.sh"

# FIXME https://github.com/actions/runner/issues/716
[[ -d "${GITHUB_ACTION_PATH}" ]] || \
    GITHUB_ACTION_PATH=/__w/_actions/${GITHUB_ACTION_PATH#/home/runner/work/_actions/}

[[ "${INPUT_DEBUG}" != "true" ]] || {
    >&2 echo "$(date +"%H:%M:%S") [INFO] Printing debug info..."
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

>&2 echo "$(date +"%H:%M:%S") [INFO] Running within ${GITHUB_ACTION_PATH}..."
cd "${GITHUB_ACTION_PATH}"

>&2 echo "$(date +"%H:%M:%S") [INFO] Generating script ${TMP_SCRIPT}..."
TMP_SCRIPT=$(mktemp)
touch ${TMP_SCRIPT}
chmod +x ${TMP_SCRIPT}
echo "#!/usr/bin/env ${INPUT_SHELL}" >> ${TMP_SCRIPT}
echo "${INPUT_RUN}" >> ${TMP_SCRIPT}

>&2 echo "$(date +"%H:%M:%S") [INFO] Running script ${TMP_SCRIPT} below..."
>&2 cat ${TMP_SCRIPT}

>&2 echo "$(date +"%H:%M:%S") [INFO] Running..."
${TMP_SCRIPT}
