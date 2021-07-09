#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)
TEMPLATE_DIR=$(cd "${SCRIPT_DIR}/../template"; pwd -P)
BIN_DIR=$(cd "${SCRIPT_DIR}/../bin"; pwd -P)

YQ=$(command -v yq || command -v "${BIN_DIR}/yq")

REPO="$1"
NAMESPACE="$2"
BANNER_LABEL="$3"
BANNER_COLOR="$4"

REPO_URL="https://${REPO}"

mkdir -p .tmpgitops

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

git clone "https://${TOKEN}@${REPO}" .tmpgitops

cd .tmpgitops || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD)

cp -R "${TEMPLATE_DIR}"/* .

# Set global.repoUrl, global.targetRevision, global.targetNamespace, global.destinations[0].targetNamespace
cat argocd/0-bootstrap/bootstrap/values.yaml | \
  "${YQ}" w - 'global.repoUrl' "${REPO_URL}" | \
  "${YQ}" w - 'global.targetRevision' "${BRANCH}" | \
  "${YQ}" w - 'global.targetNamespace' "${NAMESPACE}" > newvalues.yaml
cp newvalues.yaml argocd/0-bootstrap/bootstrap/values.yaml && rm newvalues.yaml

CLUSTER_DIR="payload/1-infrastructure/cluster"
mkdir -p ${CLUSTER_DIR}

cat > "argocd/1-infrastructure/active/cluster.yaml" <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-${BRANCH}
spec:
  destination:
    namespace: ${NAMESPACE}
    server: "https://kubernetes.default.svc"
  project: ${PROJECT}
  source:
    path: ${CLUSTER_DIR}
    repoURL: https://${APPLICATION_REPO}
    targetRevision: ${BRANCH}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

cat "${CONFIG_DIR}/console-notification-top.yaml" | \
  "${YQ}" w - 'spec.color' "${BANNER_COLOR}" | \
  "${YQ}" w - 'spec.text' "${BANNER_LABEL}" > "${CLUSTER_DIR}/console-notification-top.yaml"

cat "${CONFIG_DIR}/console-link-gitops.yaml" | \
  "${YQ}" w - 'spec.href' "https://${APPLICATION_REPO}" > "${CLUSTER_DIR}/console-link-gitops.yaml"

git add .
git commit -m "Populates initial gitops structure"
git push origin "${BRANCH}"

cd ..
rm -rf .tmpgitops
