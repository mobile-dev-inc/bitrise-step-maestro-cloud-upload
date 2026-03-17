#!/usr/bin/env bats

bats_load_library 'bats-support'
bats_load_library 'bats-assert'

setup_fake_maestro() {
  mkdir -p "$BATS_FILE_TMPDIR/bin"

  cat > "$BATS_FILE_TMPDIR/bin/maestro" << 'EOF'
#!/usr/bin/env bash
echo "App binary id: app_abc123"
echo "Visit Maestro Cloud for more details about this upload:"
echo "https://app.maestro.dev/project/proj_123/upload/upload_abc"
EOF
  chmod +x "$BATS_FILE_TMPDIR/bin/maestro"

  cat > "$BATS_FILE_TMPDIR/bin/envman" << 'EOF'
#!/usr/bin/env bash
echo "envman $*"
EOF
  chmod +x "$BATS_FILE_TMPDIR/bin/envman"

  export PATH="$BATS_FILE_TMPDIR/bin:$PATH"
  export BITRISE_SOURCE_DIR="."
}

setup_file() {
  export SCRIPT=./step.sh
  setup_fake_maestro
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
  unset debug_mode
  unset upload_name
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

@test "debug mode enabled with debug_mode input" {
  export debug_mode="yes please"

  run_script

  assert_success

  assert_output --partial "required_version=7.71.0" # A variable set for the curl check
}

@test "names with spaces are sensibly handled" {
  export upload_name="My App Test"
  
  run_script

  assert_success

  check_command_contains '--name "My App Test"'
}

@test "parses MAESTRO_CLOUD_APP_BINARY_ID from command output" {
  run_script

  assert_success
  assert_output --partial "envman add --key MAESTRO_CLOUD_APP_BINARY_ID --value app_abc123"
}

@test "parses MAESTRO_CLOUD_RUN_URL from command output" {
  run_script

  assert_success
  assert_output --partial "envman add --key MAESTRO_CLOUD_RUN_URL --value https://app.maestro.dev/project/proj_123/upload/upload_abc"
}