#!/usr/bin/env bash
set -eo pipefail

current_dir="$(basename "$(pwd)")" # e.g. requests
runtime_ver="python$(python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)" # e.g. python3.13
layer_name="${runtime_ver//./}-${current_dir}" # e.g. python313-requests
description="$(date '+%Y/%m/%d') https://github.com/tippy3/lamda-layers"

echo "Creating $layer_name"

rm -rf python layer.zip
pip install -r requirements.txt -t python
zip -r layer.zip python

layer_arn="$(aws lambda publish-layer-version \
  --zip-file fileb://layer.zip \
  --layer-name "$layer_name" \
  --description "$description" \
  --compatible-runtimes "$runtime_ver" \
  --compatible-architectures x86_64 \
  --query LayerVersionArn \
  --output text)"

echo "$layer_arn was successfully created!"
