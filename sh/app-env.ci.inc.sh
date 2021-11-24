#!/usr/bin/env bash

function ci_run_install() {
    # defer calling 'yp_ci_run_install' to the 'script' stage
    true
}


function ci_run_script_env_git() {
    make snapshot
    make dist

    # copying dist/app.zip elsewhere or else it gets deleted by
    # ci_run_script_provision: webapp_reset_to_snapshot
    export LOCAL_DIST_APP_ZIP=$(mktemp -t $(basename $(pwd)).XXXXXXXXXX)
    mv dist/app.zip ${LOCAL_DIST_APP_ZIP}

    ${GIT_ROOT}/bin/provision-env
    [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
}


function ci_run_script_env() {
    PKG_VSN=$(cat package.json | jq -r ".version")
    echo "${GIT_TAGS}" | grep -q "\bv${PKG_VSN}\b" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    # Cron jobs should just run tests (skip provision)
    if [[ "${YP_CI_IS_CRON}" = "true" ]]; then
        ${GIT_ROOT}/bin/get-snapshot
        make reset-to-snapshot
        [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
        return 0
    fi

    ${GIT_ROOT}/bin/provision-env
    [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
}


function ci_run_script_teardown_env() {
    case "${GIT_BRANCH}" in
        # handle env branches
        env/*)
            # ignore '[yp teardown-<ENV_NAME>]' commit, to allow for snapshot detection
            git reset --hard HEAD~
            ${GIT_ROOT}/bin/get-snapshot
            make reset-to-snapshot
            ;;
        # handle git-env branches
        master|*-env)
            make deps
            ;;
        *)
            echo_err "GIT_BRANCH=${GIT_BRANCH}"
            ;;
    esac

    ${GIT_ROOT}/bin/teardown-env
}


function ci_run_script() {
    # handle PRs
    [[ "${YP_CI_IS_PR}" != "true" ]] || {
        yp_ci_run_install # see ci_run_install above
        yp_ci_run_script
        return 0
    }

    # handle teardown
    local ENV_NAME=${ENV_NAME:-$(${GIT_ROOT}/bin/get-env-name)}
    local TEARDOWN_PATTERN="^\[yp teardown-${ENV_NAME}\]"
    if [[ $(git log --format=%s -n1) =~ ${TEARDOWN_PATTERN} ]] ; then
        ci_run_script_teardown_env
        return 0
    fi

    case "${GIT_BRANCH}" in
        # handle env branches
        env/*)
            ci_run_script_env
            return 0
            ;;
        # handle git-env branches
        master|*-env)
            yp_ci_run_install # see ci_run_install above
            yp_ci_run_script
            ci_run_script_env_git
            return 0
            ;;
        *)
            echo_err "GIT_BRANCH=${GIT_BRANCH}"
            ;;
    esac

    yp_ci_run_install # see ci_run_install above
    yp_ci_run_script
}

function ci_run_deploy() {
    PKG_VSN=$(cat package.json | jq -r ".version")
    echo "${GIT_TAGS}" | grep -q "\bv${PKG_VSN}\b" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    local ASSETS=${ASSETS:-$(ls dist/app.zip snapshot.zip)}

    echo_info "Assets for release:"
    echo "${ASSETS}" | while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; ls -l "${NO_XARGS_R}"; done

    local ASSETS_ARGS=$(
        echo "${ASSETS}" | \
        while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; echo "--asset ${NO_XARGS_R}"; done)
    ${YP_DIR}/bin/github-create-release \
        --repo-slug ${YP_CI_REPO_SLUG} \
        --tag "v${PKG_VSN}" \
        --body "$(cat release-notes/v${PKG_VSN}.txt)" \
        --target $(git rev-parse HEAD) \
        ${ASSETS_ARGS} \
        --token ${YP_GH_TOKEN}
}
