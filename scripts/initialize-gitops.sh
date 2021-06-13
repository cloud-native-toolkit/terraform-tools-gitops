#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
TEMPLATE_DIR=$(cd "${SCRIPT_DIR}/../template"; pwd -P)
BIN_DIR=$(cd "${SCRIPT_DIR}/../bin"; pwd -P)

YQ=$(command -v yq || command -v "${BIN_DIR}/yq")

REPO="$1"
NAMESPACE="$2"

mkdir -p .tmpgitops

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

git clone "https://${TOKEN}@${REPO}" .tmpgitops

cd .tmpgitops || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD)

cp -R "${TEMPLATE_DIR}"/* .

# Set global.repoUrl, global.targetRevision, global.targetNamespace, global.destinations[0].targetNamespace
cat argocd/0-bootstrap/bootstrap/values.yaml | \
  "${YQ}" w - 'global.repoUrl' "${REPO}" | \
  "${YQ}" w - 'global.targetRevision' "${BRANCH}" | \
  "${YQ}" w - 'global.targetNamespace' "${NAMESPACE}" | \
  "${YQ}" w - 'global.destinations[0].targetNamespace' "${NAMESPACE}" > newvalues.yaml
cp newvalues.yaml argocd/0-bootstrap/bootstrap/values.yaml && rm newvalues.yaml

git add .
git commit -m "Populates initial gitops structure"
git push origin "${BRANCH}"

cd ..
rm -rf .tmpgitops
