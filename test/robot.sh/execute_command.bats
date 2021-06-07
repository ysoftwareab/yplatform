#!/usr/bin/env bats
load '../../vendor/bats-support/load'
load '../../vendor/bats-assert/load'
load helpers

@test "execute_command doesn't accept non-LRF" {
  run execute_command "A"
  assert_failure
  assert_output --partial "Unknown command"
}

@test "execute_command correctly handles orientation when moving left" {
  POS_O=0; execute_command "L"; assert_equal "${POS_O}" 3
  POS_O=1; execute_command "L"; assert_equal "${POS_O}" 0
  POS_O=2; execute_command "L"; assert_equal "${POS_O}" 1
  POS_O=3; execute_command "L"; assert_equal "${POS_O}" 2
}

@test "execute_command correctly handles orientation when moving right" {
  POS_O=0; execute_command "R"; assert_equal "${POS_O}" 1
  POS_O=1; execute_command "R"; assert_equal "${POS_O}" 2
  POS_O=2; execute_command "R"; assert_equal "${POS_O}" 3
  POS_O=3; execute_command "R"; assert_equal "${POS_O}" 0
}

@test "execute_command correctly handles moving forward" {
  # TODO
  skip
}

@test "execute_command correctly handles hitting the walls" {
  # TODO
  skip
}
