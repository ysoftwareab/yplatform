#!/usr/bin/env bash
set -euo pipefail

SRC_FILE=.github/workflows.src/main.windows.yml

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE})"
cat ${SRC_FILE} | bin/yaml-expand
