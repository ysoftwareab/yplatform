#!/usr/bin/env bash

function sf_ci_run_before_deploy() {
    make snapshot
    make dist
}
