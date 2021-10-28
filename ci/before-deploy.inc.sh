#!/usr/bin/env bash
set -euo pipefail

function yp_ci_run_before_deploy() {
    make snapshot
    make dist
}
