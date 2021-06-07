#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "read_input_navigation requires input" {
  read_input_room_size < <(echo "3 3")
  read_input_position < <(echo "1 1 N")
  run read_input_navigation < <(echo "")
  assert_failure
  assert_output --partial "required"
}

@test "read_input_navigation accepts LRF" {
  read_input_room_size < <(echo "3 3")
  read_input_position < <(echo "1 1 N")
  run read_input_navigation < <(echo "LRFFRL")
  assert_success
}

@test "read_input_navigation doesn't accept non-LRF" {
  read_input_room_size < <(echo "3 3")
  read_input_position < <(echo "1 1 N")
  run read_input_navigation < <(echo "A")
  assert_failure
  assert_output --partial "not a sequence of LRF"
}

