# Changelog

## 1.7.0 - tbc

- Improved environment variable parsing
- Introduced tests with [BATS](https://bats-core.readthedocs.io/en/stable/)
- Reordered parameters for easier setup on bitrise.io
- Improved docs for users configuring via bitrise.yml
- Added support for App Binary ID input
- Reduce debug noise, but add a `debug_mode` option to bring it back

## 1.6.0 - 2025-11-14

- Added support for `--device-os` and `--device-model` inputs for iOS runs
- Fixed `project_id` configuration, making it a required field
- Add step documentation to the step definition, so that it appears in the Bitrise catalog
- Fixed step implementation for `app-file` and `flows` as explicit parameters rather than positional when calling Maestro CLI
- Added Maestro CLI version output to step, for debugging purposes
- Fix any remaining references to Robin

## 1.5.0 - 2024-10-07

- Add `project_id` input

## 1.4.0 - 2023-12-08

- Add `timeout` input for waiting for results

## 1.3.2 - 2023-10-27

- Fix check for curl minimum version
