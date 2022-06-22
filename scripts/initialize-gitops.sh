#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)
TEMPLATE_DIR=$(cd "${SCRIPT_DIR}/../template"; pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../chart"; pwd -P)

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v yq4 1> /dev/null 2> /dev/null; then
  echo "yq command not found" >&2
  exit 1
fi

REPO="$1"
export NAMESPACE="$2"
export SERVER_NAME="$3"

export PATH_SUFFIX="cluster/${SERVER_NAME}"
export REPO_URL="https://${REPO}"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/gitops-repo"
fi

START_DIR="${PWD}"
REPO_DIR="${TMP_DIR}/.tmpgitops"

trap "cd ${START_DIR} && rm -rf ${REPO_DIR}" EXIT

mkdir -p "${REPO_DIR}"

git clone "https://${USERNAME}:${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

git config user.email "cloudnativetoolkit@gmail.com"
git config user.name "Cloud-Native Toolkit"

if [[ -f config.yaml ]]; then
  echo "Repository already initialized. Nothing to do"
  exit 0
fi

export BRANCH=$(git rev-parse --abbrev-ref HEAD)

cp -R "${TEMPLATE_DIR}"/* .

mkdir -p "argocd/0-bootstrap/cluster/${SERVER_NAME}"

cp -R "${CHART_DIR}/bootstrap" "argocd/0-bootstrap/cluster/${SERVER_NAME}"

yq4 eval '.name = env(SERVER_NAME)' "${CHART_DIR}/bootstrap/Chart.yaml" > "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml"

cat "${CHART_DIR}/bootstrap/values.yaml" | \
  yq4 eval '.global.repoUrl = env(REPO_URL)' - | \
  yq4 eval '.global.targetRevision = env(BRANCH)' - | \
  yq4 eval '.global.targetNamespace = env(NAMESPACE)' - | \
  yq4 eval '.global.pathSuffix = env(PATH_SUFFIX)' - \
  > "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"

if [[ -n "${CONFIG}" ]]; then
  echo "${CONFIG}" | yq4 eval '.[]."argocd-config".branch = "main" | .[].payload.branch = "main" | del(.bootstrap.payload)' - > config.yaml
fi

if [[ -n "${CERT}" ]]; then
  echo "${CERT}" > kubeseal_cert.pem
fi

git add .
git commit -m "Populates initial gitops structure"
git push origin "${BRANCH}"

