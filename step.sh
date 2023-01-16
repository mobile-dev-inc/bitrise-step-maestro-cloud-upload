#!/bin/sh

# Parse env variables
envs=$(echo $env | tr "\n" "\n")
env_list=""
for e in $envs
do
    env_list+="-e $e "
done


set -ex

# Async
[ "$async" == "true" ] && is_async="true"

cd $BITRISE_SOURCE_DIR

# Install maestro CLI
curl -Ls "https://get.maestro.mobile.dev" | bash
export PATH="$PATH":"$HOME/.maestro/bin"

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
${env_list:+ $env_list} \
$app_file $workspace