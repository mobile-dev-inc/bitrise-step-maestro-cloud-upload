#!/usr/bin/env bash

# Metadata
export MDEV_CI="bitrise"

# Parse env variables
env_list_array=()
SAVEIFS=$IFS
if [ -n "$env" ]; then
    echo "DEBUG: env = '$env'"
    sanitised_env="${env//\\n/$'\n'}" # Convert \n into actual newlines
    echo "DEBUG: sanitised_env = '$sanitised_env'"
    
    IFS=$'\n'
    env_lines=($sanitised_env) # Read input into an array, splitting on newlines
    
    echo "DEBUG: env_lines = '${env_lines[*]}'"
    for line in "${env_lines[@]}"; do
        echo "DEBUG: line = '$line'"
        env_list_array+=("-e" "$line")
    done
fi
IFS=$SAVEIFS

# Refine variables
[[ "$async" == "true" ]] && is_async="true"
[[ "$export_test_report" == "true" ]] && is_export="true"

# Test report file
if [[ "$is_export" == "true" ]]; then
    if [[ -z "$export_output" ]]; then
        export_file="report.xml"
    fi
fi

if [[ -z "$app_binary_id" && -z "$app_file" ]]; then
    echo "Error: Either an App File or an App Binary ID must be provided."
    exit 1
fi

if [[ -n "$debug_mode" ]]; then
    set -ex
else
    set -e
fi


# Change to source directory
cd $BITRISE_SOURCE_DIR

# Maestro version
if [[ -z "$maestro_cli_version" ]]; then
    echo "Maestro CLI version not specified, using latest"
else
    echo "Maestro CLI version: $maestro_cli_version"
    export MAESTRO_VERSION=$maestro_cli_version;
fi

# Get the version of curl
curl_version=$(curl --version | head -n 1 | awk '{print $2}')
echo "Current curl version: $curl_version"

required_version="7.71.0"

if [ -z "${SKIP_MAESTRO_INSTALL}" ]; then # Only set in test modes
    # Compare versions and install Maestro
    if [ "$(printf '%s\n' "$required_version" "$curl_version" | sort -V | head -n1)" = "$required_version" ]; then
        # If the version of curl is greater than or equal to 7.71.0, execute with --retry-all-errors
        echo "version is higher or equal 7.71.0"
        curl --retry 5 --retry-all-errors -Ls "https://get.maestro.mobile.dev" | bash
    else
        # If the version of curl is less than 7.71.0, execute without --retry-all-errors
        echo "version is lower than 7.71.0"
        curl --retry 5 -Ls "https://get.maestro.mobile.dev" | bash
    fi

    export PATH="$PATH":"$HOME/.maestro/bin"

    echo "Maestro version:"
    maestro -v
fi

# Run Maestro Cloud
EXIT_CODE=0

if [ -n "$android_api_level" ]; then
    echo "WARN: 'android_api_level' is deprecated and will be removed in a future release. Use 'device_os' instead (e.g. device_os: android-33)."
fi

CLOUD_COMMAND=(maestro cloud \
--apiKey $api_key \
${project_id:+--project-id "$project_id"} \
${branch:+--branch "$branch"} \
${repo_name:+--repoName "$repo_name"} \
${repo_owner:+--repoOwner "$repo_owner"} \
${mapping_file:+--mapping "$mapping_file"} \
${upload_name:+--name "\"$upload_name\""} \
${is_async:+--async} \
${pull_request_id:+--pullRequestId "$pull_request_id"} \
${android_api_level:+--android-api-level "$android_api_level"} \
${device_os:+--device-os "$device_os"} \
${device_model:+--device-model "$device_model"} \
${device_locale:+--device-locale "$device_locale"} \
${include_tags:+--include-tags "$include_tags"} \
${exclude_tags:+--exclude-tags "$exclude_tags"} \
${is_export:+--format "junit"} \
${export_file:+--output "$export_file"} \
${env_list_array[@]+"${env_list_array[@]}"} \
${timeout:+--timeout "$timeout"} \
${app_binary_id:+--app-binary-id "$app_binary_id"} \
${app_file:+--app-file "$app_file"} \
--flows "$workspace")

echo "Running command:" "${CLOUD_COMMAND[@]}"

OUTPUT_FILE=$(mktemp)

"${CLOUD_COMMAND[@]}" | tee "$OUTPUT_FILE"; EXIT_CODE=${PIPESTATUS[0]}

MAESTRO_CLOUD_APP_BINARY_ID=$(grep -oE "App binary id: \S+" "$OUTPUT_FILE" | awk '{print $NF}')
envman add --key MAESTRO_CLOUD_APP_BINARY_ID --value "$MAESTRO_CLOUD_APP_BINARY_ID"
MAESTRO_CLOUD_RUN_URL=$(grep -oE "https://app\.maestro\.dev\S+" "$OUTPUT_FILE" | head -n 1)
envman add --key MAESTRO_CLOUD_RUN_URL --value "$MAESTRO_CLOUD_RUN_URL"

rm -f "$OUTPUT_FILE"

# Export test results
if [[ -n "$export_file" && -f "$export_file" ]]; then
    test_run_dir="$BITRISE_TEST_RESULT_DIR/maestro"
    mkdir "$test_run_dir"
    cp "$export_file" "$test_run_dir/maestro_report.xml"
    echo '{"maestro-test-report":"Maestro Cloud Flows"}' >> "$test_run_dir/test-info.json"
fi

exit $EXIT_CODE
