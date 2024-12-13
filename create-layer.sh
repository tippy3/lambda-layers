#!/usr/bin/env bash
set -eo pipefail

current_dir="$(basename "$(pwd)")" # e.g. requests
runtime_ver="python$(python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)" # e.g. python3.13
layer_name="${runtime_ver//./}-${current_dir}" # e.g. python313-requests
description="$(date '+%Y/%m/%d') https://github.com/tippy3/lambda-layers"

function clean_up() {
  rm -rf python layer.zip
}
trap clean_up EXIT

function info_log() {
  ESC=$(printf '\033')
  printf "${ESC}[32m%s${ESC}[m\n" "$1"
}

info_log "packaging $layer_name ..."

pip install -r requirements.txt -t python
zip -r layer.zip python

info_log "creating $layer_name ..."

aws lambda publish-layer-version \
  --zip-file fileb://layer.zip \
  --layer-name "$layer_name" \
  --description "$description" \
  --compatible-runtimes "$runtime_ver" \
  --compatible-architectures x86_64 \
  --query LayerVersionArn \
  --output text
