#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

export SF_CI_ECHO_BENCHMARK=${GIT_ROOT}/sf-ci-echo-benchmark

GITHUB_JOB=${GITHUB_JOB:-main}

case ${GITHUB_JOB} in
    mainc*|deployc*)
        source .ci.container.sh
        ;;
    main*)
        source .ci.main.sh
        ;;
    *)
        echo_err "Unknown GITHUB_JOB=${GITHUB_JOB}."
        exit 1
esac
