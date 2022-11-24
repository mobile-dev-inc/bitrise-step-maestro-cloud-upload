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
${repoName:+--repoName "$repoName"} \
${repoOwner:+--repoOwner "$repoOwner"} \
${mapping_file:+--mapping "$mapping_file"} \
${upload_name:+--name "$upload_name"} \
${is_async:+--async} \
${pullRequestId:+--pullRequestId "$pullRequestId"} \
${env_list:+ $env_list} \
$app_file $workspace