#!/usr/bin/env bash
set -euo pipefail

function sf_ci_run_script() {
    # skip running 'make deps' again (part of 'sf_ci_run_install' already)
    # make all test
    make build check test
}
