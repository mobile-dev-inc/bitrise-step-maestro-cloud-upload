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
${BITRISE_GIT_BRANCH:+--branch "$BITRISE_GIT_BRANCH"} \
${BITRISEIO_GIT_REPOSITORY_SLUG:+--repoName "$BITRISEIO_GIT_REPOSITORY_SLUG"} \
${BITRISEIO_GIT_REPOSITORY_OWNER:+--repoOwner "$BITRISEIO_GIT_REPOSITORY_OWNER"} \
${mapping_file:+--mapping "$mapping_file"} \
${upload_name:+--name "$upload_name"} \
${is_async:+--async} \
${pullRequestId:+--pullRequestId "$BITRISE_PULL_REQUEST"} \
${env_list:+ $env_list} \
$app_file $workspace