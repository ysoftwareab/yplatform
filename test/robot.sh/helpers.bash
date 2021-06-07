#!/usr/bin/env bash

function setup() {
  SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

  BATS_TEST_SKIPPED=${BATS_TEST_SKIPPED:-}
  source ${SUPPORT_FIRECLOUD_DIR}/bin/robot.sh
}
