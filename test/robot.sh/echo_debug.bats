#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "echo_debug is silent when DEBUG is empty" {
  RANDOM_STR=$(${SUPPORT_FIRECLOUD_DIR}/bin/random-hex)
  run echo_debug "${RANDOM_STR}"
  assert_success
  refute_output --partial "[ERR ] ${RANDOM_STR}"
}

@test "echo_debug prints when DEBUG is non-empty" {
  RANDOM_STR=$(${SUPPORT_FIRECLOUD_DIR}/bin/random-hex)
  function fn() {
    # shellcheck disable=SC2034
    DEBUG=1
    echo_debug "${RANDOM_STR}"
  }
  run fn
  assert_success
  assert_output --partial "[DEBU] ${RANDOM_STR}"
}
