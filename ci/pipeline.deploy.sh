#!/usr/bin/env bash
set -euo pipefail

# don't deploy from PRs ever
[[ "${SF_CI_IS_PR}" != "true" ]] || exit 0

./.ci.sh before_deploy

./.ci.sh deploy

./.ci.sh after_deploy
