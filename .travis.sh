#!/usr/bin/env bash
set -euo pipefail

travis_run_script() {
    make
    [ "${TRAVIS_EVENT_TYPE}" = "pull_request" ] || \
        make is-decrypted
}

source support-firecloud/repo/dot.travis.sh
