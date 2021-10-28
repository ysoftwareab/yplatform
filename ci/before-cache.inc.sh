#!/usr/bin/env bash
set -euo pipefail

function yp_ci_run_before_cache_stats() {
    echo_do "Showing cache stats..."

    [[ "${TRAVIS:-}" != "true" ]] || {
        local YAML2JSON="npx js-yaml"
        for f in $(eval "${YAML2JSON} .travis.yml" | jq -r ".cache.directories[]"); do
            eval "f=${f}"
            [[ -d "${f}" ]] || continue
            du -hcs ${f} | head -n+1
        done
    }

    echo_done
}


function yp_ci_run_before_cache() {
    yp_ci_run_before_cache_stats || true
}
