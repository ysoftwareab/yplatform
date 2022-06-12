#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
YP_DOCKER_CI_IMAGE=false
DOCKER_ORG=${DOCKER_ORG:-ysoftwareab}

# publish to docker.io (aka hub.docker.com) if given
# DOCKER_USERNAME/DOCKER_TOKEN

# publish to ghcr.io (aka docker.pkg.github.com) if given
# GH_USERNAME/GH_TOKEN

function ci_run_before_deploy() {
    true
}

function ci_run_deploy_docker_image() {
    # NOTE jq must be preinstalled

    ARG_FROM=

    # shellcheck disable=SC1091
    local DOCKER_OS_RELEASE_ID="$(source ${YP_DIR}/dockerfiles/yp-${GITHUB_MATRIX_CONTAINER}/os-release && echo ${ID})" # editorconfig-checker-disable-line
    # shellcheck disable=SC1091
    local DOCKER_OS_RELEASE_VERSION_ID="$(source ${YP_DIR}/dockerfiles/yp-${GITHUB_MATRIX_CONTAINER}/os-release && echo ${VERSION_ID:-0})" # editorconfig-checker-disable-line
    case ${DOCKER_OS_RELEASE_ID} in
        alpine)
            # track minor for alpine, not patch
            # shellcheck disable=SC2206
            DOCKER_OS_RELEASE_VERSION_ID_ARR=( ${DOCKER_OS_RELEASE_VERSION_ID//./ } )
            DOCKER_OS_RELEASE_VERSION_ID=${DOCKER_OS_RELEASE_VERSION_ID_ARR[0]}.${DOCKER_OS_RELEASE_VERSION_ID_ARR[1]}
            ;;
        *)
            ;;
    esac
    # shellcheck disable=SC1091
    local DOCKER_IMAGE_NAME=yp-${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_ID}-${GITHUB_MATRIX_YP_CI_BREW_INSTALL} # editorconfig-checker-disable-line
    local DOCKER_IMAGE_TAG=$(cat package.json | jq -r ".version")

    if [[ -f ${YP_DIR}/dockerfiles/build.FROM_TAG ]]; then
        ARG_FROM_TAG=$(cat ${YP_DIR}/dockerfiles/build.FROM_TAG)
        ARG_FROM=${DOCKER_ORG}/yp-${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_ID}-${GITHUB_MATRIX_YP_CI_BREW_INSTALL}:${ARG_FROM_TAG} # editorconfig-checker-disable-line
    else
        [[ "${YP_DEPLOY_DRYRUN:-}" = "true" ]] || [[ "${GITHUB_MATRIX_YP_CI_BREW_INSTALL}" != "common" ]] || {
            ARG_FROM=${DOCKER_ORG}/yp-${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_ID}-minimal:${DOCKER_IMAGE_TAG} # editorconfig-checker-disable-line
        }
    fi

    local TIMESTAMP_LATEST=$(
        curl -qfsSL https://hub.docker.com/v2/repositories/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}/tags/latest | \
            jq -r .last_updated | \
            while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; date +%s -d "${NO_XARGS_R}"; done || \
            echo 0)

    local TAGS=()
    TAGS+=("${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}")

    # DONT USE ghcr.io aka docker.pkg.github.com
    # 1. it requires credentials even for downloading *public* packages
    # 2. *public* packages cannot be deleted, neither entirely, nor specific versions
    # https://help.github.com/en/github/managing-packages-with-github-packages/deleting-a-package
    # TAGS+=("ghcr.io/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}")

    # don't push as 'latest' tag if the tag has been updated after the current commit
    if [[ $(git show -s --format=%ct HEAD) -ge ${TIMESTAMP_LATEST} ]]; then
        TAGS+=("${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:latest")
        # see above
        # TAGS+=("ghcr.io/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:latest")
    fi

    [[ -z "${DOCKER_USERNAME:-}" ]] || [[ -z "${DOCKER_TOKEN:-}" ]] || {
        [[ -n "${YP_DEPLOY_DRYRUN:-}" ]] || YP_DEPLOY_DRYRUN=false
        echo "${DOCKER_TOKEN}" | exe docker login -u "${DOCKER_USERNAME}" --password-stdin
    }
    # see above
    # [[ -z "${GH_USERNAME:-}" ]] || [[ -z "${GH_TOKEN:-}" ]] || {
    #     [[ -n "${YP_DEPLOY_DRYRUN:-}" ]] || YP_DEPLOY_DRYRUN=false
    #     echo "${GH_TOKEN}" | exe docker login -u ${GH_USERNAME} --password-stdin ghcr.io
    # }

    PLATFORMS_ARM64="--platforms linux/arm64"
    # [[ "${YP_DEPLOY_DRYRUN:-}" != "true" ]] || PLATFORMS_ARM64=
    # .github/workflows/{main,deploy}c.yml would change the current builder to 'localamd64-remotearm64'
    # if there's a remote arm64 server up and running
    docker buildx inspect | head -n1 | grep -q -Fx "Name: localamd64-remotearm64" || PLATFORMS_ARM64=
    case ${GITHUB_MATRIX_CONTAINER} in
        ubuntu-20.04)
            true
            ;;
        *)
            PLATFORMS_ARM64=
            ;;
    esac

    ${YP_DIR}/dockerfiles/yp-${GITHUB_MATRIX_CONTAINER}/build \
        --platforms linux/amd64 \
        ${PLATFORMS_ARM64} \
        --name "${DOCKER_IMAGE_NAME}" \
        --tags $(IFS=,; echo "${TAGS[*]}") \
        $([[ -z "${ARG_FROM}" ]] || echo "--from" "${ARG_FROM}") \
        --yp-ci-brew-install "${GITHUB_MATRIX_YP_CI_BREW_INSTALL}" \
        $([[ "${YP_DEPLOY_DRYRUN:-}" = "true" ]] || echo "--push")

}

function ci_run_deploy() {
    [[ "${YP_DEPLOY_DRYRUN:-}" = "true" ]] || {
        PKG_VSN=$(cat package.json | jq -r ".version")
        echo "${GIT_TAGS}" | grep -q "\v${PKG_VSN}\b" || {
            echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
            return 1
        }
    }

    ci_run_deploy_docker_image
}

source "${YP_DIR}/repo/dot.ci.sh.yp"
