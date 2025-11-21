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