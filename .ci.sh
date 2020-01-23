#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

SF_TRAVIS_DOCKER_IMAGE=false
DOCKER_ORG=${DOCKER_ORG:-tobiipro}

function ci_run_before_deploy() {
    true
}

function ci_run_deploy_docker_image_hubdockercom() {
    [[ -n "${DOCKER_USERNAME:-}" ]] || return
    [[ -n "${DOCKER_TOKEN:-}" ]] || return

    echo "${DOCKER_TOKEN}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

    local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG}..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image_dockerpkggithubcom() {
    [[ -n "${GH_TOKEN:-}" ]] || return

    local GH_DOCKER_HUB=docker.pkg.github.com

    echo "${GH_TOKEN}" | docker login -u tobiiprotools --password-stdin ${GH_DOCKER_HUB}

    local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG}..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image() {
    [[ -e "/etc/os-release" ]] || return

    [[ "${SF_CI_BREW_INSTALL}" != "dev" ]] || SF_CI_BREW_INSTALL=common

    local RELEASE_ID="$(source /etc/os-release && echo ${ID})"
    local RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"
    local RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
    local DOCKER_IMAGE_NAME=sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}-${SF_CI_BREW_INSTALL}
    local DOCKER_IMAGE_TAG=$(cat package.json | jq -r ".version")
    local DOCKERFILE=${SUPPORT_FIRECLOUD_DIR}/dockerfiles/sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}/Dockerfile
    [[ -f "${DOCKERFILE}" ]] || return

    # NOTE jq must be preinstalled
    local TIMESTAMP_LATEST=$(
        curl https://hub.docker.com/v2/repositories/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}/tags/latest | \
            jq -r .last_updated | \
            xargs -0 date +%s -d || \
            echo 0)

    exe docker build . \
        --file ${DOCKERFILE} \
        --tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
        --build-arg FROM=${RELEASE_ID}:${RELEASE_VERSION_ID} \
        --build-arg IMAGE_NAME=${DOCKER_IMAGE_NAME} \
        --build-arg IMAGE_TAG=${DOCKER_IMAGE_TAG} \
        --build-arg SF_CI_BREW_INSTALL=${SF_CI_BREW_INSTALL}

    # don't push as 'latest' tag if the tag has been updated after the current commit
    local PUBLISH_AS_LATEST_TAG=false
    if [[ $(git show -s --format=%ct HEAD) -ge ${TIMESTAMP_LATEST} ]]; then
        PUBLISH_AS_LATEST_TAG=true
    fi
    ci_run_deploy_docker_image_hubdockercom ${PUBLISH_AS_LATEST_TAG}
    ci_run_deploy_docker_image_dockerpkggithubcom ${PUBLISH_AS_LATEST_TAG}
}

function ci_run_deploy() {
    PKG_VSN=$(cat package.json | jq -r ".version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    ci_run_deploy_docker_image
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
