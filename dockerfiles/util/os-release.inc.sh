#!/usr/bin/env bash
set -euo pipefail

OS_RELEASE_FILE=${OS_RELEASE_DIR}/os-release

DOCKER_OS_RELEASE_ID="$(source ${OS_RELEASE_FILE} && echo ${ID})"
DOCKER_OS_RELEASE_VERSION_ID="$(source ${OS_RELEASE_FILE} && echo ${VERSION_ID:-0})"
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

OS_RELEASE_BASE=
OS_RELEASE_COMMAND=
case ${DOCKER_OS_RELEASE_ID}-${DOCKER_OS_RELEASE_VERSION_ID} in
    alpine-*)
        OS_RELEASE_BASE=ruby:2.6-alpine${DOCKER_OS_RELEASE_VERSION_ID}
        # shellcheck disable=SC2209,SC2034
        OS_RELEASE_COMMAND=sh
        ;;
    amzn-*)
        OS_RELEASE_BASE=amazonlinux:latest
        ;;
    arch-0)
        OS_RELEASE_BASE=archlinux:latest
        ;;
    centos-*)
        OS_RELEASE_BASE=quay.io/centos/centos:stream${DOCKER_OS_RELEASE_VERSION_ID}
        ;;
    rhel-*)
        OS_RELEASE_BASE=redhat/ubi8:${DOCKER_OS_RELEASE_VERSION_ID}
        ;;
    *)
        # shellcheck disable=SC2034
        OS_RELEASE_BASE=${DOCKER_OS_RELEASE_ID}:${DOCKER_OS_RELEASE_VERSION_ID}
        ;;
esac
