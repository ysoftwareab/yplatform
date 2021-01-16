#!/usr/bin/env bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "requires CI_COMMIT_REF_SLUG environment variable" {
  unset CI_COMMIT_REF_SLUG
  assert_empty "${CI_COMMIT_REF_SLUG}"
  run some_command
  assert_failure
  assert_output --partial "CI_COMMIT_REF_SLUG"
}
