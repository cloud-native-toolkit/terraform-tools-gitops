#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

export PATH="${BIN_DIR}:${PATH}"

export GIT_HOST=$(echo "${INPUT}" | jq -r '.host')
export GIT_ORG=$(echo "${INPUT}" | jq -r '.org')
export GIT_PROJECT=$(echo "${INPUT}" | jq -r '.project')
export GIT_USERNAME=$(echo "${INPUT}" | jq -r '.username')
export GIT_TOKEN=$(echo "${INPUT}" | jq -r '.token')
export CA_CERT=$(echo "${INPUT}" | jq -r '.ca_cert | @base64d')

REPO=$(echo "${INPUT}" | jq -r '.repo')
TMP_DIR=$(echo "${INPUT}" | jq -r '.tmp_dir')

OUTPUT=$(igc gitops-init "${REPO}" --tmpDir "${TMP_DIR}" --output json)

REPO_OUT=$(echo "${OUTPUT}" | jq -r '.repo')
URL_OUT=$(echo "${OUTPUT}" | jq -r '.url')
GITOPS_CONFIG=$(echo "${OUTPUT}" | jq -c '.gitopsConfig')
GIT_CREDENTIALS=$(jq -n -c --arg REPO "${REPO_OUT}" --arg URL "${URL_OUT}" --arg USERNAME "${GIT_USERNAME}" --arg TOKEN "${GIT_TOKEN}" '[{"repo": $REPO, "url": $URL, "username": $USERNAME, "token": $TOKEN}]')

jq -n --arg REPO "${REPO_OUT}" --arg URL "${URL_OUT}" --arg CONFIG "${GITOPS_CONFIG}" --arg CREDENTIALS "${GIT_CREDENTIALS}" '{"repo": $REPO, "url": $URL, "config": $CONFIG, "credentials": $CREDENTIALS}'
