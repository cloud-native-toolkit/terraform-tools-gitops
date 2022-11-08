#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_USERNAME=$(cat git_username)
GIT_TOKEN=$(cat git_token)
CERT=$(cat sealed_secrets_cert)
BIN_DIR=$(cat .bindir)

SERVER_NAME="default"

echo "Bin dir: ${BIN_DIR}"
ls "${BIN_DIR}"

export PATH="${BIN_DIR}:${PATH}"

mkdir -p .testrepo

git clone "https://${GIT_USERNAME}:${GIT_TOKEN}@${GIT_REPO}" .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml" ]]; then
  echo "ArgoCD bootstrap chart - argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml"
  exit 1
fi

CHART_NAME=$(yq eval '.name' "argocd/0-bootstrap/cluster/${SERVER_NAME}/Chart.yaml")
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

VALUES_PATH_SUFFIX=$(yq eval '.global.pathSuffix' "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml")
if [[ "${VALUES_PATH_SUFFIX}" != "cluster/${SERVER_NAME}" ]]; then
  echo "global.pathSuffix value in values.yaml does not match expected: ${VALUES_PATH_SUFFIX}"
  exit 1
fi

REPO_CERT=$(cat kubeseal_cert.pem)

if [[ "${REPO_CERT}" != "${CERT}" ]]; then
  echo "Certs don't match!!"
  echo ""
  echo "*** Repo cert"
  echo "${REPO_CERT}"
  echo ""
  echo "*** Module cert"
  echo "${CERT}"
  exit 1
fi

cd ..
rm -rf .testrepo
