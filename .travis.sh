#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

travis_run_after_script() {
    sf_travis_run_after_script_upload_job_artifacts
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.travis.sh.sf"
