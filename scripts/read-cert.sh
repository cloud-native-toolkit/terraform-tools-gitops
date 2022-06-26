#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]*)".*/\1/g')

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

REPO=$(echo "${INPUT}" | jq -r '.repo // empty')
USERNAME=$(echo "${INPUT}" | jq -r '.username // empty')
TOKEN=$(echo "${INPUT}" | jq -r '.token // empty')
TMP_DIR=$(echo "${INPUT}" | jq -r '.tmp_dir // empty')

if [[ -z "${REPO}" ]] || [[ -z "${USERNAME}" ]] || [[ -z "${TOKEN}" ]]; then
  echo "The repo, username, and token must be passed in a JSON object via stdin" >&2
  exit 1
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/gitops-repo"
fi

REPO_DIR="${TMP_DIR}/gitops-cert"
START_DIR="${PWD}"

mkdir -p "${REPO_DIR}"

trap "cd ${START_DIR} && rm -rf ${REPO_DIR}" EXIT

git clone "https://${USERNAME}:${TOKEN}@${REPO}" "${REPO_DIR}" 1> /dev/null 2> /dev/null

cd "${REPO_DIR}" || exit 1

if [[ -f kubeseal_cert.pem ]]; then
  jq -n --rawfile CERT kubeseal_cert.pem '{"cert": $CERT}'
else
  jq -n '{"cert": ""}'
fi
