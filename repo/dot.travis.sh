#!/usr/bin/env bash
set -euo pipefail

# travis_run_<step>() {
# }

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.travis.sh.sf"
