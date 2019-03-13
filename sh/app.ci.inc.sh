#!/usr/bin/env bash

ci_run_script_provision_env_git() {
    make snapshot
    make dist

    # copying dist/app.zip elsewhere or else it gets deleted by
    # ci_run_script_provision: webapp_reset_to_snapshot
    export LOCAL_DIST_APP_ZIP=$(mktemp -t $(basename $(pwd)).XXXXXXXXXX)
    mv dist/app.zip ${LOCAL_DIST_APP_ZIP}

    bin/provision-env
    [[ ! -f bin/test-env ]] || bin/test-env
}


ci_run_script_provision_env() {
    PKG_VSN=$(cat package.json | json "version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    # Cron jobs should just run tests (skip provision)
    if [[ "${CI_IS_CRON}" = "true" ]] ; then
        make reset-to-snapshot
        ci_run_script_test
        return 0
    fi

    bin/provision-env
    [[ ! -f bin/test-env ]] || bin/test-env
}


ci_run_install() {
    true
}


ci_run_script_teardown_env() {
    bin/teardown-env
}


ci_run_script() {
    export ENV_NAME=$(${SUPPORT_FIRECLOUD_DIR}/bin/app-get-env-name)

    case ${GIT_BRANCH} in
        env/*)
            true
            ;;
        *)
            sf_ci_run_script
            ;;
    esac

    [[ "${CI_IS_PR}" != "true" ]] || return 0

    case ${GIT_BRANCH} in
        env/*)
            local TEARDOWN_PATTERN="^\[TEARDOWN-ENV ${ENV_NAME}\]"
            if [[ $(git log --format=%s -n1) =~ ${TEARDOWN_PATTERN} ]] ; then
                ci_run_script_teardown_env
                return 0
            fi

            ci_run_script_provision_env
            return 0
            ;;
        master|*-env)
            ci_run_script_provision_env_git
            return 0
            ;;
    esac
}
