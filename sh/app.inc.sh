#!/usr/bin/env bash

set -a
[[ ! -f ${GIT_ROOT}/CONST.inc ]] || source ${GIT_ROOT}/CONST.inc
set +a

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${GLOBAL_AWS_REGION}}
export AWS_REGION=${AWS_REGION:-${AWS_DEFAULT_REGION}}

[[ ! -x "${GIT_ROOT}/bin/get-env-name" ]] || ENV_NAME=${ENV_NAME:-$(${GIT_ROOT}/bin/get-env-name)}

function app_get_snapshot() {
    # deprecated
    ${GIT_ROOT}/bin/get-snapshot
}

function app_reset_to_snapshot() {
    # deprecated
    make reset-to-snapshot
}

function app_get_dist() {
    # deprecated
    ${GIT_ROOT}/bin/get-dist
}

function app_reset_to_dist() {
    # deprecated
    make reset-to-dist
}

function app_assume_aws_credentials() {
    echo_do "Impersonating ${AWS_ACCOUNT_PREFIX} credentials..."
    for PREFIX_AWS_VAR in $(printenv | grep -o "^${AWS_ACCOUNT_PREFIX}_AWS[^=]\+" ); do
        AWS_VAR=${PREFIX_AWS_VAR/#${AWS_ACCOUNT_PREFIX}_/}
        export eval "${AWS_VAR}=${!PREFIX_AWS_VAR}"
    done
    export AWS_REGION=${AWS_REGION:-${GLOBAL_AWS_REGION}}
    echo_done
}


function app_provision_cfn_stack() {
    local STACK_STEM=$1
    local TRAVIS_WAIT_INTERVAL=$2
    local TRAVIS_WAIT_MAX=$3
    local TRAVIS_WAIT_LOG="${STACK_STEM}.${STACK_ITERATION}.travis-wait.log"

    local STACK_ITERATION=${STACK_ITERATION:-1}

    local STACK_NAME=${STACK_STEM/#env/${ENV_NAME}}
    local STACK_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/aws-get-stack-id --stack-name ${STACK_NAME} || true)

    echo_do "Provisioning CloudFormation ${STACK_NAME}..."
    (
        cd cfn
        if [[ -z "${STACK_ID}" ]]; then
            echo_info "Stack ${STACK_NAME} did not exist..."
            make ${STACK_STEM}.cfn.json

            [[ "${DRYRUN:-}" = "true" ]] || {
                # FIXME see https://github.com/m3t/travis_wait
                # make ${STACK_STEM}.cfn.json/exec
                ${SUPPORT_FIRECLOUD_DIR}/bin/travis-wait \
                    -i ${TRAVIS_WAIT_INTERVAL} \
                    -l ${TRAVIS_WAIT_MAX} \
                    "make ${STACK_STEM}.cfn.json/exec" \
                    "${TRAVIS_WAIT_LOG}" || {
                    cat "${TRAVIS_WAIT_LOG}"
                    exit 1
                }
                cat "${TRAVIS_WAIT_LOG}"
            }
        else
            echo_info "Stack ${STACK_NAME} already exists..."
            make ${STACK_STEM}.change-set.json

            [[ "${DRYRUN:-}" = "true" ]] || {
                # FIXME see https://github.com/m3t/travis_wait
                # make ${STACK_STEM}.change-set.json/exec
                ${SUPPORT_FIRECLOUD_DIR}/bin/travis-wait \
                    -i ${TRAVIS_WAIT_INTERVAL} \
                    -l ${TRAVIS_WAIT_MAX} \
                    "make ${STACK_STEM}.change-set.json/exec" \
                    "${TRAVIS_WAIT_LOG}" || {
                    cat "${TRAVIS_WAIT_LOG}"
                    exit 1
                }
                cat "${TRAVIS_WAIT_LOG}"
            }
        fi
    )
    echo_done
}


function app_provision_cfn_stacks() {
    local STACK_STEMS=$1
    STACK_STEMS="$(echo "${STACK_STEMS}" | tr "," " ")"
    shift

    # Running stacks provision in multiple iterations
    # STACK_ITERATION is needed when you have cross-stack mutual blocking dependencies
    declare -A STACK_ITERATIONS
    for STACK_STEM in ${STACK_STEMS}; do
        STACK_ITERATIONS[${STACK_STEM}]=$((${STACK_ITERATIONS[${STACK_STEM}]:-0} + 1))
        export STACK_ITERATION=${STACK_ITERATIONS[${STACK_STEM}]}

        app_provision_cfn_stack ${STACK_STEM} $@
    done
}


function app_teardown_cfn_stack() {
    local STACK_STEM=$1
    local TRAVIS_WAIT_INTERVAL=$2
    local TRAVIS_WAIT_MAX=$3
    local TRAVIS_WAIT_LOG="${STACK_STEM}.travis-wait.log"
    local TRAVIS_WAIT_ALLOW_APPEND=1

    local STACK_NAME=${STACK_STEM/#env-/${ENV_NAME}-}
    local STACK_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/aws-get-stack-id --stack-name ${STACK_NAME} || true)

    [ -n "${STACK_ID}" ] || {
        echo_skip "Stack ${STACK_NAME} for env ${ENV_NAME} not found"
    }

    [ -z "${STACK_ID}" ] || (
        echo_info "Found CFN stack ${STACK_ID}"
        echo_do "Tearing down stack ${STACK_NAME}..."
        exe cd ${GIT_ROOT}/cfn

        ${SUPPORT_FIRECLOUD_DIR}/bin/travis-wait \
            -i ${TRAVIS_WAIT_INTERVAL} \
            -l ${TRAVIS_WAIT_MAX} \
            -a ${TRAVIS_WAIT_ALLOW_APPEND} \
            "make ${STACK_STEM}.cfn.json/rm" \
            "${TRAVIS_WAIT_LOG}" || {
            cat "${TRAVIS_WAIT_LOG}"
            exit 1
        }
        cat "${TRAVIS_WAIT_LOG}"
        echo_done
    )

    STACK_ID=$(${SUPPORT_FIRECLOUD_DIR}/bin/aws-get-stack-id --stack-name ${STACK_NAME} || true)
    [ -z "${STACK_ID}" ] || (
        echo_err "Teardown of stack ${STACK_NAME} failed"
        exit 1
    )
}


function app_teardown_cfn_stacks() {
    local STACK_STEMS=$1
    STACK_STEMS="$(echo "${STACK_STEMS}" | tr "," " ")"
    shift

    # Running stacks provision in multiple iterations
    # STACK_ITERATION is needed when you have cross-stack mutual blocking dependencies
    declare -A STACK_ITERATIONS
    for STACK_STEM in ${STACK_STEMS}; do
        STACK_ITERATIONS[${STACK_STEM}]=$((${STACK_ITERATIONS[${STACK_STEM}]:-0} + 1))
        export STACK_ITERATION=${STACK_ITERATIONS[${STACK_STEM}]}

        app_teardown_cfn_stack ${STACK_STEM} $@
    done
}
