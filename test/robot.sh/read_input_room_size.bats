#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "read_input_room_size requires input" {
  run read_input_room_size < <(echo "")
  assert_failure
  assert_output --partial "required"
}

@test "read_input_room_size accepts positive integers" {
  # NOTE alternative style in order to access variables
  # run read_input_room_size < <(echo "1 1")
  read_input_room_size < <(echo "1 1")
  # assert_success
  assert_equal "$?" 0
  assert_equal "${ROOM_WIDTH}" 1
  assert_equal "${ROOM_DEPTH}" 1
  assert_equal "${MAX_POS_X}" 0
  assert_equal "${MAX_POS_Y}" 0
}

@test "read_input_room_size doesn't accept 0" {
  run read_input_room_size < <(echo "0 1")
  assert_failure
  assert_output --partial "not a positive integer"
}

@test "read_input_room_size doesn't accept negative integers" {
  run read_input_room_size < <(echo "-1 1")
  assert_failure
  assert_output --partial "not a positive integer"
}
