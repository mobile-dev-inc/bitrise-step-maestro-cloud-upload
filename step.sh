#!/bin/sh

# Metadata
export MDEV_CI="bitrise"

# Parse env variables
envs=$(echo $env | tr "\n" "\n")
env_list=""
for e in $envs
do
    env_list+="-e $e "
done


set -ex

# Refine variables
[[ "$async" == "true" ]] && is_async="true"
[[ "$export_format" == "true" ]] && is_export="true"
[[ "$is_export" == "true" && -n "$export_output" ]] && export_file="$export_output"

cd $BITRISE_SOURCE_DIR

# Maestro version
if [[ -z "$maestro_cli_version" ]]; then
    echo "Maestro CLI version not specified, using latest"
else
    echo "Maestro CLI version: $maestro_cli_version"
    export MAESTRO_VERSION=$maestro_cli_version;
fi

# Install maestro CLI
curl -Ls "https://get.maestro.mobile.dev" | bash
export PATH="$PATH":"$HOME/.maestro/bin"

ls -a $BITRISE_SOURCE_DIR
ls -a $BITRISE_SOURCE_DIR/android/

# Export test results
if [[ "$is_export" == "true" ]]; then
    test_run_dir="$BITRISE_TEST_RESULT_DIR/maestro_test_output"
    mkdir "$test_run_dir"
    cp "$export_file" "$test_run_dir/maestro_report.xml"
    echo '{"maestro-cloud-flows":"Maestro Cloud Flows"}' >> "$test_run_dir/test-info.json"
fi

# Run Maestro Cloud
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
${include_tags:+--include-tags "$include_tags"} \
${exclude_tags:+--exclude-tags "$exclude_tags"} \
${is_export:+--format "junit"} \
${export_file:+--output "$export_file"} \
${env_list:+ $env_list} \
$app_file $workspace