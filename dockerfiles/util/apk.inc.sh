#!/usr/bin/env bash
set -euo pipefail

function apk_update() {
    apk update
}

function apk_install_one() {
    local PKG="$*"
    apk add --no-cache "${PKG}"
}
