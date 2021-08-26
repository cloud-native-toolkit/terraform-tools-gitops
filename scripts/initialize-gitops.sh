#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)
TEMPLATE_DIR=$(cd "${SCRIPT_DIR}/../template"; pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../chart"; pwd -P)

YQ=$(command -v "${BIN_DIR}/yq4")

REPO="$1"
export NAMESPACE="$2"
export SERVER_NAME="$3"
BANNER_LABEL="$4"
BANNER_COLOR="$5"

export PATH_SUFFIX="cluster/${SERVER_NAME}"
export REPO_URL="https://${REPO}"

mkdir -p .tmpgitops

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

git clone "https://${TOKEN}@${REPO}" .tmpgitops

cd .tmpgitops || exit 1

export BRANCH=$(git rev-parse --abbrev-ref HEAD)

cp -R "${TEMPLATE_DIR}"/* .

mkdir -p "argocd/0-bootstrap/cluster/${SERVER_NAME}"

cp -R "${CHART_DIR}/bootstrap" "argocd/0-bootstrap/cluster/${SERVER_NAME}"

"${YQ}" eval '.name = env(SERVER_NAME)' "${CHART_DIR}/bootstrap/Chart.yaml" > "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml"

cat "${CHART_DIR}/bootstrap/values.yaml" | \
  "${YQ}" eval '.global.repoUrl = env(REPO_URL)' - | \
  "${YQ}" eval '.global.targetRevision = env(BRANCH)' - | \
  "${YQ}" eval '.global.targetNamespace = env(NAMESPACE)' - | \
  "${YQ}" eval '.global.pathSuffix = env(PATH_SUFFIX)' - > "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"

if [[ -n "${CONFIG}" ]]; then
  echo "${CONFIG}" | ${YQ} eval '.[]."argocd-config".branch = "main" | .[].payload.branch = "main" | del(.bootstrap.payload)' - > config.yaml
fi

if [[ -n "${CERT}" ]]; then
  echo "${CERT}" > kubeseal_cert.pem
fi

git add .
git commit -m "Populates initial gitops structure"
git push origin "${BRANCH}"

cd ..
rm -rf .tmpgitops
