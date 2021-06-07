#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "echo_x prints and dies" {
  RANDOM_STR=$(${SUPPORT_FIRECLOUD_DIR}/bin/random-hex)
  run echo_x "${RANDOM_STR}"
  assert_output --partial "[ERR ] ${RANDOM_STR}"
  assert_failure
}
