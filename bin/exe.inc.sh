#!/usr/bin/env bash
set -euo pipefail

export PATH=/usr/local/bin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}

function exe() {
    echo "$(pwd)\$ $@"
    "$@"
}

function echo_next() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[NEXT]" "$@"
}

function echo_do() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[DO  ]" "$@"
}

function echo_done() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[DONE]" "$@"
}

function echo_info() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[INFO]" "$@"
}

function echo_skip() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[SKIP]" "$@"
}

function echo_warn() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[WARN]" "$@"
}

function echo_err() {
    ${SUPPORT_FIRECLOUD_DIR}/bin/ci-echo "[ERR ]" "$@"
}

function sh_script_usage() {
    grep "^##" "${0}" | cut -c 4-
    exit 1
}

function sh_script_version() {
    grep "^#-" "${0}" | cut -c 4-
    exit 1
}

function printenv_with_name() {
    for f in $*; do
        echo "${f}=$(printenv ${f} || echo "")"
    done
}

function printenv_uniq() {
    tac | sort -u -t= -k1,1 | sed "/=$$/d" | sed "/=%/d" | sed "/^$$/d"
}
