# Upload to Maestro Cloud

Upload your app binary to Maestro Cloud and run your flows.

Run your flows on [Maestro Cloud](https://app.maestro.dev/).

## Configuration

The minimum required configuration is to provide an API key, Project ID and an app binary (an x86 compatible APK for Android, or a Simulator build packaged in a zip archive for iOS).

If your tests are anywhere but the default `.maestro` folder in the root of your project, you should set the Flow Workspace.

Full list of step options:

| Name                       | Key                   | Required | Description                                                                                                                                                  |
| -------------------------- | --------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| API Key                    | `api_key`             | Yes      | Maestro Cloud API key, available in [Maestro Cloud](https://app.maestro.dev)                                                                                 |
| Maestro Cloud Project ID   | `project_id`          | Yes      | Which project to run the tests against                                                                                                                       |
| App File                   | `app_file`            | No       | Path to the app file to upload. This, or App Binary ID, must be provided.                                                                                    |
| App Binary ID              | `app_binary_id`       | No       | The unique identifier of the app binary in Maestro Cloud. This, or App File, must be provided.                                                               |
| Flow workspace             | `workspace`           | No       | Path to Maestro flows (default: `.maestro`)                                                                                                                  |
| Upload Name                | `upload_name`         | No       | Friendly name of the run                                                                                                                                     |
| Async Mode                 | `async`               | No       | Whether to start the flow and exit the action (defaults to `false`)                                                                                          |
| Environment variables      | `env`                 | No       | Environment variables to pass to the run                                                                                                                     |
| Android API level          | `android_api_level`   | No       | **Deprecated.** Use `device_os` instead (e.g. `android-33`).                                                                                                 |
| Device OS                  | `device_os`           | No       | The [device OS version](https://docs.maestro.dev/cloud/reference/configuring-os-version) to use. iOS: `iOS-16-2`, `iOS-17-5`, `iOS-18-2`, etc. Android: `android-33`, `android-34`, etc. |
| Device model               | `device_model`        | No       | The [device model](https://docs.maestro.dev/cloud/reference/configuring-os-version#using-a-specific-ios-minor-version-and-device-recommended). iOS: `iPhone-11`, `iPhone-11-Pro`, etc. Android: `pixel_6`, `pixel_7`, etc. |
| Device locale              | `device_locale`       | No       | The [device locale](https://docs.maestro.dev/cloud/reference/configuring-device-locale) to use when running the flows (eg en_US)                             |
| Include tags               | `include_tags`        | No       | Comma-separated list of tags to include in the run                                                                                                           |
| Exclude tags               | `exclude_tags`        | No       | Comma-separated list of tags to exclude from the run                                                                                                         |
| Export test report (JUnit) | `export_test_report`  | No       | Generate test suite report (JUnit)                                                                                                                           |
| Export test output         | `export_output`       | No       | Export test file output (Default: report.xml)                                                                                                                |
| Mapping File               | `mapping_file`        | No       | Path to the ProGuard map (Android) or dSYM (iOS)                                                                                                             |
| Build branch               | `branch`              | No       | The branch this upload originated from                                                                                                                       |
| Repository name            | `repo_name`           | No       | Repository name (ie: GitHub repo slug)                                                                                                                       |
| Repository owner           | `repo_owner`          | No       | Repository owner (ie: GitHub organization or user slug)                                                                                                      |
| Pull request ID            | `pull_request_id`     | No       | The ID of the pull request this upload originated from                                                                                                       |
| Maestro CLI version        | `maestro_cli_version` | No       | Maestro CLI version to be downloaded in your CI (Default: latest)                                                                                            |
| Timeout                    | `timeout`             | No       | How long to wait for the run to complete when not async (defaults to 30 minutes)                                                                             |
| Debug Mode                 | `debug_mode`          | No       | Prints shell commands as they execute. Set to any non-blank value to enable.                                                                                 |

## Outputs

| Name                        | Key                          | Description                                                                                                 |
| --------------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Maestro Cloud App Binary ID | `MAESTRO_CLOUD_APP_BINARY_ID`| The unique identifier of the uploaded app binary — can be reused in future uploads to skip re-uploading.     |
| Maestro Cloud Run URL       | `MAESTRO_CLOUD_RUN_URL`      | The URL to view this test run in Maestro Cloud.                                                             |

See the [Changelog](https://github.com/mobile-dev-inc/bitrise-step-maestro-cloud-upload/blob/main/CHANGELOG.md) for recent updates.

## Contributing

Issues and pull requests are welcome at [github.com/mobile-dev-inc/bitrise-step-maestro-cloud-upload](https://github.com/mobile-dev-inc/bitrise-step-maestro-cloud-upload/issues).

The step is implemented in [step.sh](step.sh). Inputs are declared in [step.yml](step.yml). Changes to docs should be reflected both here and in the step.yml (which is used on the Bitrise catalogue page).

### Testing

To test changes to this step:

- Install BATS and its libraries by running `npm install -g bats bats-support bats-assert`
- Run the tests with the npm-installed libs by setting `BATS_LIB_PATH`:

```bash
BATS_LIB_PATH=`npm root -g` bats test.bats
```
