#!/bin/sh

# Metadata
export MDEV_CI="bitrise"

# Parse env variables
env_list=""
if [ -n "$env" ]; then
    # Replace '\n' with ' -e '
    envs="${env//\\n/ -e }"
    # Prefix the whole string with '-e '
    env_list="-e $envs"
fi

# Refine variables
[[ "$async" == "true" ]] && is_async="true"
[[ "$export_test_report" == "true" ]] && is_export="true"

# Test report file
if [[ "$is_export" == "true" ]]; then
    if [[ -z "$export_output" ]]; then
        export_file="report.xml"
    fi
fi

set -ex

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

# Function to compare versions
version_compare() {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # Fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # Fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# Install maestro CLI
version_compare "$curl_version" "7.71.0"
if [[ $? -eq 2 ]]; then
    echo "version is higher or equal 7.71.0"
    # If the version of curl is greater than 7.71.0, execute with --retry-all-errors
    curl --retry 5 --retry-all-errors -Ls "https://get.maestro.mobile.dev" | bash
else
    echo "version is lower than 7.71.0"
    # If the version of curl is less than or equal to 7.71.0, execute without --retry-all-errors
    curl --retry 5 -Ls "https://get.maestro.mobile.dev" | bash
fi
export PATH="$PATH":"$HOME/.maestro/bin"

# Run Maestro Cloud
EXIT_CODE=0

maestro cloud \
--apiKey $api_key \
${branch:+--branch "$branch"} \
${repo_name:+--repoName "$repo_name"} \
${repo_owner:+--repoOwner "$repo_owner"} \
${mapping_file:+--mapping "$mapping_file"} \
${upload_name:+--name "$upload_name"} \
${is_async:+--async} \
${pull_request_id:+--pullRequestId "$pull_request_id"} \
${android_api_level:+--android-api-level "$android_api_level"} \
${ios_version:+--ios-version "$ios_version"} \
${device_locale:+--device-locale "$device_locale"} \
${include_tags:+--include-tags "$include_tags"} \
${exclude_tags:+--exclude-tags "$exclude_tags"} \
${is_export:+--format "junit"} \
${export_file:+--output "$export_file"} \
${env_list:+ $env_list} \
$app_file $workspace || EXIT_CODE=$?

# Export test results
if [[ -n "$export_file" && -f "$export_file" ]]; then
    test_run_dir="$BITRISE_TEST_RESULT_DIR/maestro"
    mkdir "$test_run_dir"
    cp "$export_file" "$test_run_dir/maestro_report.xml"
    echo '{"maestro-test-report":"Maestro Cloud Flows"}' >> "$test_run_dir/test-info.json"
fi

exit $EXIT_CODE
