#!/usr/bin/env bats

bats_load_library 'bats-support'
bats_load_library 'bats-assert'

setup_file() {
  export SCRIPT=./step.sh
  export BATS_TEST_MODE=true
}

setup() {
  # Set the default settings
  export SKIP_MAESTRO_INSTALL="yes"
  
  # Set the default parameters
  export api_key="rb_123"
  export project_id="proj_123"
  export app_file="app.apk"
  export workspace="flows"

  # Unset all optional parameters
  unset env
  unset app_binary_id
}

run_script() {
    run bash "$SCRIPT"
}

check_command_contains() {
    expected="$1"
    regexp="Running command: .*${expected}.*"
    assert_line --regexp "$regexp"
}

@test "constructs command with required parameters" {
  run_script

  assert_success

  assert_line "Running command: maestro cloud --apiKey rb_123 --project-id proj_123 --app-file app.apk --flows flows"
}

@test "parses 1 env parameter" {
  export env="FOO=value"

  run_script

  assert_success

  check_command_contains "-e FOO=value"
}

@test "parses multiple env parameters" {
  export env='FOO=value\nBAR=another'

  run_script

  assert_success

  check_command_contains "-e FOO=value -e BAR=another"
}

@test "parses multiple env parameters over multiple lines" {
  export env='FOO=value
BAR=another'

  run_script

  assert_success

  check_command_contains "-e FOO=value -e BAR=another"
}

@test "constructs command with app_binary_id parameter" {
  # Set app_binary_id and remove the default app_file
  export app_binary_id="ab_456"
  unset app_file

  run_script

  assert_success

  check_command_contains "--app-binary-id ab_456"
}

@test "fails when neither app_file nor app_binary_id provided" {
  # Unset both to simulate missing inputs
  unset app_file
  unset app_binary_id

  run_script

  assert_failure

  assert_output --partial "Error: Either an App File or an App Binary ID must be provided."
}

@test "includes both app_file and app_binary_id when both provided" {
  export app_binary_id="ab_456"
  # `app_file` already set by `setup()`

  run_script

  assert_success

  check_command_contains "--app-binary-id ab_456"
  check_command_contains "--app-file app.apk"
  # This is correct - when a user specifies both, the `maestro cloud` command will favour the app_binary_id
}