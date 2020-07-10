#!/usr/bin/env bash

function sf_ci_run_before_cache_brew() {
    which brew >/dev/null 2>&1 || return 0
    local HOMEBREW_PREFIX=$(brew --prefix)
    local CI_CACHE_HOMEBREW_PREFIX
    brew cleanup

    case $(uname -s) in
        Darwin)
            CI_CACHE_HOMEBREW_PREFIX=~/.homebrew
            ;;
        Linux)
            CI_CACHE_HOMEBREW_PREFIX=~/.linuxbrew
            ;;
        *)
            echo_err "${FUNCNAME[0]}: $(uname -s) is an unsupported OS."
            return 1
            ;;
    esac

    local HOMEBREW_PREFIX_FULL=$(cd ${HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
    local CI_CACHE_HOMEBREW_PREFIX_FULL=$(cd ${CI_CACHE_HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
    if [[ "${HOMEBREW_PREFIX_FULL}" = "${CI_CACHE_HOMEBREW_PREFIX_FULL}" ]]; then
        return 0
    fi

    echo_do "brew: Caching ${HOMEBREW_PREFIX}/Homebrew..."
    mkdir -p ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew
    rsync -aW --inplace --delete \
        ${HOMEBREW_PREFIX}/Homebrew/ \
        ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew/
    echo_done
}


function sf_ci_run_before_cache_stats() {
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


function sf_ci_run_before_cache() {
    sf_ci_run_before_cache_brew
    sf_ci_run_before_cache_stats || true
}
