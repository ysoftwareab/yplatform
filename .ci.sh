#!/usr/bin/env bash
set -euo pipefail

# YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/yplatform" && pwd)"
YP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${YP_DIR}/sh/common.inc.sh

export YP_CI_ECHO_BENCHMARK=${GIT_ROOT}/sf-ci-echo-benchmark

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
