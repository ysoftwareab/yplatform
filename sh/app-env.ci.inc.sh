#!/usr/bin/env bash

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
    PKG_VSN=$(cat package.json | json "version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    # Cron jobs should just run tests (skip provision)
    if [[ "${CI_IS_CRON}" = "true" ]]; then
        ${GIT_ROOT}/bin/get-snapshot
        make reset-to-snapshot
        [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
        return 0
    fi

    ${GIT_ROOT}/bin/provision-env
    [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
}


function ci_run_install() {
    true
}


function ci_run_script_teardown_env() {
    ${GIT_ROOT}/bin/teardown-env
}


function ci_run_script() {
    case ${GIT_BRANCH} in
        env/*)
            true
            ;;
        *)
            sf_ci_run_script
            ;;
    esac

    [[ "${CI_IS_PR}" != "true" ]] || return 0

    local ENV_NAME=${ENV_NAME:-$(${GIT_ROOT}/bin/get-env-name)}
    local TEARDOWN_PATTERN="^\[TEARDOWN-ENV ${ENV_NAME}\]"
    if [[ $(git log --format=%s -n1) =~ ${TEARDOWN_PATTERN} ]] ; then
        ci_run_script_teardown_env
        return 0
    fi

    case ${GIT_BRANCH} in
        env/*)
            ci_run_script_env
            return 0
            ;;
        master|*-env)
            ci_run_script_env_git
            return 0
            ;;
    esac
}

function ci_run_deploy() {
    local GIT_TAG=$(git tag -l --points-at HEAD | head -1)
    local ASSETS=${ASSETS:-$(ls dist/app.zip snapshot.zip)}

    echo_info "Assets for release:"
    echo "${ASSETS}" | xargs ls -l

    local ASSETS_ARGS=$(
        echo "${ASSETS}" | \
        xargs -I {} echo "--asset {}"
    )
    ${SUPPORT_FIRECLOUD_DIR}/bin/github-create-release \
        --repo-slug ${CI_REPO_SLUG} \
        --tag ${GIT_TAG} \
        --target $(git rev-parse HEAD) \
        ${ASSETS_ARGS} \
        --token ${GH_TOKEN}
}
