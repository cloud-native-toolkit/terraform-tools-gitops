#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

SERVER_NAME="default"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml" ]]; then
  echo "ArgoCD bootstrap missing - argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"
  exit 1
fi

echo "Printing argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml"
cat argocd/0-bootstrap/cluster/${SERVER_NAME}/values.yaml

cd ..
rm -rf .testrepo
