#!/usr/bin/env bash
set -euo pipefail

export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source ${SUPPORT_FIRECLOUD_DIR}/sh/core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/exe.inc.sh
