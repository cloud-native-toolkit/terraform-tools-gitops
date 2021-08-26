#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)
TEMPLATE_DIR=$(cd "${SCRIPT_DIR}/../template"; pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../chart"; pwd -P)

YQ=$(command -v "${BIN_DIR}/yq4")

REPO="$1"
NAMESPACE="$2"
SERVER_NAME="$3"
BANNER_LABEL="$4"
BANNER_COLOR="$5"

REPO_URL="https://${REPO}"

mkdir -p .tmpgitops

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

git clone "https://${TOKEN}@${REPO}" .tmpgitops

cd .tmpgitops || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD)

cp -R "${TEMPLATE_DIR}"/* .

mkdir -p "argocd/0-bootstrap/cluster/${SERVER_NAME}"

cp -R "${CHART_DIR}/bootstrap" "argocd/0-bootstrap/cluster/${SERVER_NAME}"

cat "${CHART_DIR}/bootstrap/Chart.yaml" | \
  "${YQ}" w - 'name' "${SERVER_NAME}" > "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml"

cat "${CHART_DIR}/bootstrap/values.yaml" | \
  "${YQ}" w - 'global.repoUrl' "${REPO_URL}" | \
  "${YQ}" w - 'global.targetRevision' "${BRANCH}" | \
  "${YQ}" w - 'global.targetNamespace' "${NAMESPACE}" | \
  "${YQ}" w - 'global.pathSuffix' "cluster/${SERVER_NAME}" > "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"


if [[ -n "${CONFIG}" ]]; then
  echo "${CONFIG}" | yq eval '.[]."argocd-config".branch = "main" | .[].payload.branch = "main" | del(.bootstrap.payload)' - > config.yaml
fi

if [[ -n "${CERT}" ]]; then
  echo "${CERT}" > kubeseal_cert.pem
fi

git add .
git commit -m "Populates initial gitops structure"
git push origin "${BRANCH}"

cd ..
rm -rf .tmpgitops
