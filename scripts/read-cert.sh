#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]*)".*/\1/g')
REPO=$(echo "${INPUT}" | grep "repo" | sed -E 's/.*"repo": ?"([^"]*)".*/\1/g')
TOKEN=$(echo "${INPUT}" | grep "token" | sed -E 's/.*"token": ?"([^"]*)".*/\1/g')

mkdir -p .tmpgitopscert

git clone "https://${TOKEN}@${REPO}" .tmpgitopscert 1> /dev/null 2> /dev/null

cd .tmpgitopscert || exit 1

if [[ -f kubeseal_cert.pem ]]; then
  echo "{}" | ${BIN_DIR}/jq --rawfile CERT kubeseal_cert.pem '{"cert": $CERT}'
else
  echo '{"cert": ""}'
fi

cd ..
rm -rf .tmpgitopscert
