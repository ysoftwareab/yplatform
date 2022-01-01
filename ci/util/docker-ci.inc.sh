#!/usr/bin/env bash
set -euo pipefail

function yp_run_docker_ci_login() {
    YP_DOCKER_CI_USERNAME="${YP_DOCKER_CI_USERNAME:-${DOCKER_USERNAME:-}}"
    YP_DOCKER_CI_TOKEN="${YP_DOCKER_CI_TOKEN:-${DOCKER_TOKEN:-}}"

    [[ -n "${YP_DOCKER_CI_USERNAME:-}" ]] || return
    [[ -n "${YP_DOCKER_CI_TOKEN:-}" ]] || return
    echo "${YP_DOCKER_CI_TOKEN}" | \
        exe docker login -u "${YP_DOCKER_CI_USERNAME}" --password-stdin ${YP_DOCKER_CI_SERVER:-}
}

function yp_run_docker_ci_image() {
    local YP_DOCKER_CI_IMAGE=${1}
    local MOUNT_DIR=${2:-${PWD}}
    local CONTAINER_NAME=${3:-yp-docker-ci}

    local GID2=$(id -g)
    local UID2=$(id -u)
    local GNAME=$(id -g -n)
    local UNAME=$(id -u -n)

    echo_do "Spinning up Docker for ${YP_DOCKER_CI_IMAGE}..."

    echo | docker login | grep -q "Login Succeeded" || yp_run_docker_ci_login

    echo_do "Pulling ${YP_DOCKER_CI_IMAGE} image..."
    exe docker pull ${YP_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Running the ${CONTAINER_NAME} container..."
    echo_info "Proxying relevant env vars."
    echo_info "Mounting RW ${MOUNT_DIR} folder."
    exe docker run -d -it --rm \
        --platform linux/amd64 \
        --privileged \
        --name ${CONTAINER_NAME} \
        --hostname ${CONTAINER_NAME} \
        --add-host ${CONTAINER_NAME}:127.0.0.1 \
        --network=host \
        --ipc=host \
        --volume "${MOUNT_DIR}:${MOUNT_DIR}:rw" \
        --env CI=true \
        --env USER=${UNAME} \
        --env-file <(${YP_DIR}/bin/travis-get-env-vars) \
        ${YP_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Instrumenting the ${CONTAINER_NAME} container..."
    exe docker exec -it --user root ${CONTAINER_NAME} \
        touch /yplatform.docker-ci

    # create same group (and gid) that the 'travis' user has, inside the docker container
    exe docker exec -it --user root ${CONTAINER_NAME} \
        bash -c "cat /etc/group | cut -d\":\" -f3 | grep -q \"^${GID2}$\" || \
            ${YP_DIR}/bin/linux-addgroup --gid ${GID2} \"${GNAME}\""

    local GNAME_REAL=$(docker exec -it --user root ${CONTAINER_NAME} \
        getent group ${GID2} | cut -d: -f1)

    # create same user (and uid) that the 'travis' user has, inside the docker container
    exe docker exec -it --user root ${CONTAINER_NAME} \
        ${YP_DIR}/bin/linux-adduser \
        --force-badname \
        --uid ${UID2} \
        --ingroup ${GNAME_REAL} \
        --home ${HOME} \
        --shell /bin/sh \
        --disabled-password \
        "${UNAME}"

    exe docker exec -it --user root ${CONTAINER_NAME} \
        ${YP_DIR}/bin/linux-adduser2group \
        --force-badname \
        "${UNAME}" \
        sudo;

    exe docker exec -it --user root ${CONTAINER_NAME} \
        bash -c "echo \"${UNAME} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
    exe docker exec -it --user root ${CONTAINER_NAME} \
        bash -c "echo \"Defaults:${UNAME} !env_reset\" >> /etc/sudoers"
    exe docker exec -it --user root ${CONTAINER_NAME} \
        bash -c "echo \"Defaults:${UNAME} !secure_path\" >> /etc/sudoers"

    # if ${MOUNT_DIR} is under ${HOME}, make sure parents of ${MOUNT_DIR} up to ${HOME} inclusive are writeable
    # to allow for special folders/files e.g. ~/.cache to be accessible for writing
    [[ "${MOUNT_DIR#"${HOME}"}" = "${MOUNT_DIR}" ]] || {
        echo_do "Taking ownership over parents of ${MOUNT_DIR} up to ${HOME}..."
        CHOWN_PWD="${MOUNT_DIR}"
        while true; do
            exe docker exec -it --user root ${CONTAINER_NAME} \
                bash -c "chown ${UID2}:${GID2} ${CHOWN_PWD}"
            echo_done
            [[ "${CHOWN_PWD}" != "${HOME}" ]] || break
            CHOWN_PWD="$(dirname "${CHOWN_PWD}")"
        done
        unset CHOWN_PWD
    }

    echo_done # "Instrumenting the ${CONTAINER_NAME} container..."

    echo_done # "Spinning up Docker for ${YP_DOCKER_CI_IMAGE}..."
}


function yp_get_docker_ci_image() {
    # sync with dockerfiles/util/build line:~93 "NAME=yp-..."
    [[ -n "${YP_DOCKER_CI_IMAGE:-}" ]] || \
        YP_DOCKER_CI_IMAGE=ysoftwareab/yp-${OS_RELEASE_ID}-${OS_RELEASE_VERSION_ID}-minimal # editorconfig-checker-disable-line
    # if given a ysoftwareab/yp- image, but without a tag,
    # set the tag to the version of YP
    if [[ ${YP_DOCKER_CI_IMAGE} =~ ^(docker\.io/)?ysoftwareab/yp- ]] && \
        [[ ! "${YP_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(cat ${YP_DIR}/package.json | jq -r ".version")
        YP_DOCKER_CI_IMAGE="${YP_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi
    # if given a (ghcr.io|docker.pkg.github.com)/ysoftwareab/yplatform/yp- image, but without a tag
    # set the tag to the version of YP
    if [[ ${YP_DOCKER_CI_IMAGE} =~ ^(ghcr\.io|docker\.pkg\.github\.com)?/ysoftwareab/yplatform/yp- ]] && \
        [[ ! "${YP_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(cat ${YP_DIR}/package.json | jq -r ".version")
        YP_DOCKER_CI_IMAGE="${YP_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi

    echo "${YP_DOCKER_CI_IMAGE}"
}
