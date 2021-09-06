#!/usr/bin/env bash
set -euo pipefail

function sf_ci_run_before_deploy() {
    make snapshot
    make dist
}
