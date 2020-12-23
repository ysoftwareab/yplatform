#!/usr/bin/env bash

# when not in CI, use dev install
[[ "${CI:-}" = "true" ]] || SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL:-dev}

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-${SF_CI_BREW_INSTALL}.inc.sh
[[ "${${SF_CI_BREW_INSTALL}}" != "minimal" ]] || source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-node.inc.sh
