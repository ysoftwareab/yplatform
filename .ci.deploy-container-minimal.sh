#!/usr/bin/env bash

# shellcheck disable=SC2034
SF_DOCKER_CI_IMAGE=false
DOCKER_ORG=${DOCKER_ORG:-rokmoln}

# publish to hub.docker.com if given
# DOCKER_USERNAME/DOCKER_TOKEN

# publish to docker.pkg.github.com if given
# GH_USERNAME/GH_TOKEN

function ci_run_before_deploy() {
    true
}

function ci_run_deploy_docker_image_hubdockercom() {
    [[ -n "${DOCKER_USERNAME:-}" ]] || return 0
    [[ -n "${DOCKER_TOKEN:-}" ]] || return 0

    echo "${DOCKER_TOKEN}" | exe docker login -u "${DOCKER_USERNAME}" --password-stdin

    local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG} to hub.docker.com..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image_dockerpkggithubcom() {
    [[ -n "${GH_USERNAME:-}" ]] || return 0
    [[ -n "${GH_TOKEN:-}" ]] || return 0

    local GH_DOCKER_HUB=docker.pkg.github.com

    echo "${GH_TOKEN}" | exe docker login -u ${GH_USERNAME} --password-stdin ${GH_DOCKER_HUB}

    local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG} to ${GH_DOCKER_HUB}..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image() {
    # NOTE jq must be preinstalled

    DOCKER_IMAGE_FROM=

    # shellcheck disable=SC1091
    local DOCKER_OS_RELEASE_ID="$(source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/${GITHUB_MATRIX_CONTAINER}/os-release && echo ${ID})" # editorconfig-checker-disable-line
    # shellcheck disable=SC1091
    local DOCKER_OS_RELEASE_VERSION_ID="$(source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/${GITHUB_MATRIX_CONTAINER}/os-release && echo ${VERSION_ID:-0})" # editorconfig-checker-disable-line
    # shellcheck disable=SC1091
    local DOCKER_OS_RELEASE_VERSION_CODENAME="$(source ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/${GITHUB_MATRIX_CONTAINER}/os-release && echo ${VERSION_CODENAME:-})" # editorconfig-checker-disable-line
    local DOCKER_IMAGE_NAME=sf-${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_CODENAME:-${DOCKER_OS_RELEASE_VERSION_ID}}-${GITHUB_MATRIX_SF_CI_BREW_INSTALL} # editorconfig-checker-disable-line
    local DOCKER_IMAGE_TAG=$(cat package.json | jq -r ".version")

    [[ "${SF_DEPLOY_DRYRUN:-}" = "true" ]] || {
        [[ "${GITHUB_MATRIX_SF_CI_BREW_INSTALL}" != "common" ]] || \
            DOCKER_IMAGE_FROM=${DOCKER_ORG}/sf-${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_CODENAME:-${DOCKER_OS_RELEASE_VERSION_ID}}-minimal:${DOCKER_IMAGE_TAG} # editorconfig-checker-disable-line
    }

    local TIMESTAMP_LATEST=$(
        curl -qfsSL https://hub.docker.com/v2/repositories/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}/tags/latest | \
            jq -r .last_updated | \
            while read -r NO_XARGS_R; do [[ -n "${NO_XARGS_R}" ]] || continue; date +%s -d "${NO_XARGS_R}"; done || \
            echo 0)

    ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/${GITHUB_MATRIX_CONTAINER}/build \
        --docker-image-from "${DOCKER_IMAGE_FROM}" \
        --docker-image-name "${DOCKER_IMAGE_NAME}" \
        --docker-image-tag "${DOCKER_IMAGE_TAG}" \
        --sf-ci-brew-install "${GITHUB_MATRIX_SF_CI_BREW_INSTALL}"

    [[ "${SF_DEPLOY_DRYRUN:-}" != "true" ]] || {
        echo_info "SF_DEPLOY_DRYRUN=${SF_DEPLOY_DRYRUN}"
        echo_skip "Pushing to docker registries..."
        return 0
    }
    # don't push as 'latest' tag if the tag has been updated after the current commit
    local PUBLISH_AS_LATEST_TAG=false
    if [[ $(git show -s --format=%ct HEAD) -ge ${TIMESTAMP_LATEST} ]]; then
        PUBLISH_AS_LATEST_TAG=true
    fi

    ci_run_deploy_docker_image_hubdockercom ${PUBLISH_AS_LATEST_TAG}

    # DONT USE docker.pkg.github.com
    # 1. it requires credentials even for downloading *public* packages
    # 2. *public* packages cannot be deleted, neither entirely, nor specific versions
    # https://help.github.com/en/github/managing-packages-with-github-packages/deleting-a-package
    # ci_run_deploy_docker_image_dockerpkggithubcom ${PUBLISH_AS_LATEST_TAG}
}

function ci_run_deploy() {
    [[ "${SF_DEPLOY_DRYRUN:-}" = "true" ]] || {
        PKG_VSN=$(cat package.json | jq -r ".version")
        echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
            echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
            return 1
        }
    }

    ci_run_deploy_docker_image
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
