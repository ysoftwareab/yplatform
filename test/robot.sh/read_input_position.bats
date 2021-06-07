#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "read_input_position requires input" {
  read_input_room_size < <(echo "3 3")
  run read_input_position < <(echo "")
  assert_failure
  assert_output --partial "required"
}

@test "read_input_position accepts positive integers" {
  read_input_room_size < <(echo "3 3")
  # NOTE alternative style in order to access variables
  # run read_input_position < <(echo "1 1 N")
  read_input_position < <(echo "1 1 N")
  # assert_success
  assert_equal "$?" 0
  assert_equal "${POS_X}" 1
  assert_equal "${POS_Y}" 1
  assert_equal "${POS_O}" 0
}

@test "read_input_position accepts 0" {
  read_input_room_size < <(echo "3 3")
  run read_input_position < <(echo "0 1 N")
  assert_success
}

@test "read_input_position doesn't accept negative integers" {
  read_input_room_size < <(echo "3 3")
  run read_input_position < <(echo "-1 1 N")
  assert_failure
  assert_output --partial "not a positive integer"
}

@test "read_input_position is limited by read_input_room_size" {
  read_input_room_size < <(echo "1 1")
  run read_input_position < <(echo "1 1 N")
  assert_failure
  assert_output --partial "larger than room"
}

@test "read_input_position doesn't accept non-NESW" {
  read_input_room_size < <(echo "3 3")
  run read_input_position < <(echo "1 1 A")
  assert_failure
  assert_output --partial "not a NESW"
}

