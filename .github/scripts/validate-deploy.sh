#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)
BIN_DIR=$(cat .bindir)

SERVER_NAME="default"

YQ=$(command -v "${BIN_DIR}/yq4")

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml" ]]; then
  echo "ArgoCD bootstrap chart - argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml"
  exit 1
fi

CHART_NAME=$(${YQ} eval '.name' "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml")
if [[ "${CHART_NAME}" != "${SERVER_NAME}" ]]; then
  echo "Chart name does not match server name: ${CHART_NAME}"
  exit 1
fi

if [[ ! -f "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml" ]]; then
  echo "ArgoCD bootstrap missing - argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"
  exit 1
fi

echo "Printing argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"
cat argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml

VALUES_PATH_SUFFIX=$(${YQ} eval '.global.pathSuffix' "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml")
if [[ "${VALUES_PATH_SUFFIX}" != "cluster/${SERVER_NAME}" ]]; then
  echo "global.pathSuffix value in values.yaml does not match expected: ${VALUES_PATH_SUFFIX}"
  exit 1
fi

cd ..
rm -rf .testrepo
