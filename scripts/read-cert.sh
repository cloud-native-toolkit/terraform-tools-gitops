#!/usr/bin/env bash

REPO="$1"
CERT_FILE="$2"

CERT_DIR=$(dirname "${CERT_FILE}")
mkdir -p "${CERT_DIR}"

mkdir -p .tmpgitopscert

git clone "https://${TOKEN}@${REPO}" .tmpgitopscert

cd .tmpgitopscert || exit 1

if [[ -f kubeseal_cert.pem ]]; then
  cat kubeseal_cert.pem > "${CERT_FILE}"
else
  touch "${CERT_FILE}"
fi

cd ..
rm -rf .tmpgitopscert
