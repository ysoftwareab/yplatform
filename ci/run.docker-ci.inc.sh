#!/usr/bin/env bash

function sf_run_docker_ci_login() {
    SF_DOCKER_CI_USERNAME="${SF_DOCKER_CI_USERNAME:-${DOCKER_USERNAME:-}}"
    SF_DOCKER_CI_TOKEN="${SF_DOCKER_CI_TOKEN:-${DOCKER_TOKEN:-}}"

    [[ -n "${SF_DOCKER_CI_USERNAME:-}" ]] || return
    [[ -n "${SF_DOCKER_CI_TOKEN:-}" ]] || return
    echo "${SF_DOCKER_CI_TOKEN}" | exe docker login -u "${SF_DOCKER_CI_USERNAME}" --password-stdin ${SF_DOCKER_CI_SERVER:-} # editorconfig-checker-disable-line
}

function sf_run_docker_ci_image() {
    local SF_DOCKER_CI_IMAGE=${1}
    local MOUNT_DIR=${2:-${PWD}}
    local CONTAINER_NAME=${3:-sf-docker-ci}

    local GID2=$(id -g)
    local UID2=$(id -u)
    local GNAME=$(id -g -n)
    local UNAME=$(id -u -n)

    echo_do "Spinning up Docker for ${SF_DOCKER_CI_IMAGE}..."

    echo | docker login | grep -q "Login Succeeded" || sf_run_docker_ci_login

    echo_do "Pulling ${SF_DOCKER_CI_IMAGE} image..."
    exe docker pull ${SF_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Running the ${CONTAINER_NAME} container, proxying relevant env vars and mounting ${MOUNT_DIR} folder..."
    exe docker run -d -it --rm \
        --privileged \
        --name ${CONTAINER_NAME} \
        --hostname ${CONTAINER_NAME} \
        --add-host ${CONTAINER_NAME}:127.0.0.1 \
        --network=host \
        --ipc=host \
        --volume "${MOUNT_DIR}:${MOUNT_DIR}:rw" \
        --env CI=true \
        --env USER=${UNAME} \
        --env-file <(${SUPPORT_FIRECLOUD_DIR}/bin/travis-get-env-vars) \
        ${SF_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Instrumenting the ${CONTAINER_NAME} container..."
    exe docker exec -it -u root ${CONTAINER_NAME} \
        touch /support-firecloud.docker-ci

    # create same group (and gid) that the 'travis' user has, inside the docker container
    exe docker exec -it -u root ${CONTAINER_NAME} \
        bash -c "cat /etc/group | cut -d\":\" -f3 | grep -q \"^${GID2}$\" || \
            $(SUPPORT_FIRECLOUD_DIR)/bin/linux-addgroup --gid ${GID2} \"${GNAME}\""

    local GNAME_REAL=$(docker exec -it -u root ${CONTAINER_NAME} \
        getent group ${GID2} | cut -d: -f1)

    # create same user (and uid) that the 'travis' user has, inside the docker container
    exe docker exec -it -u root ${CONTAINER_NAME} \
        ${SUPPORT_FIRECLOUD_DIR}/bin/linux-adduser \
        --force-badname \
        --uid ${UID2} \
        --ingroup ${GNAME_REAL} \
        --home ${HOME} \
        --shell /bin/sh \
        --disabled-password \
        "${UNAME}"

    exe docker exec -it -u root ${CONTAINER_NAME} \
        ${SUPPORT_FIRECLOUD_DIR}/bin/linux-adduser2group \
        --force-badname \
        "${UNAME}" \
        sudo;

    exe docker exec -it -u root ${CONTAINER_NAME} \
        bash -c "echo \"${UNAME} ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
    exe docker exec -it -u root ${CONTAINER_NAME} \
        bash -c "echo \"Defaults:${UNAME} !env_reset\" >> /etc/sudoers"
    exe docker exec -it -u root ${CONTAINER_NAME} \
        bash -c "echo \"Defaults:${UNAME} !secure_path\" >> /etc/sudoers"

    # if ${MOUNT_DIR} is under ${HOME}, make sure ${HOME} is writeable
    # to allow for special folders/files e.g. ~/.cache to be accessible for writing
    echo_do "Taking ownership over ${HOME}..."
    exe docker exec -it -u root ${CONTAINER_NAME} \
        chown ${UID2}:${GID2} ${HOME}
    echo_done

    echo_done # "Instrumenting the ${CONTAINER_NAME} container..."

    echo_done # "Spinning up Docker for ${SF_DOCKER_CI_IMAGE}..."
}


function sf_get_docker_ci_image() {
    [[ -n "${SF_DOCKER_CI_IMAGE:-}" ]] || \
        SF_DOCKER_CI_IMAGE=rokmoln/sf-${OS_RELEASE_ID}-${OS_RELEASE_VERSION_CODENAME:-${OS_RELEASE_VERSION_ID}}-minimal
    # if given a rokmoln/sf- image, but without a tag,
    # set the tag to the version of SF
    if [[ ${SF_DOCKER_CI_IMAGE} =~ ^rokmoln/sf- ]] && \
        [[ ! "${SF_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(
            cat ${SUPPORT_FIRECLOUD_DIR}/package.json | ${SUPPORT_FIRECLOUD_DIR}/bin/jq -r ".version")
        SF_DOCKER_CI_IMAGE="${SF_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi
    # if given a docker.pkg.github.com/rokmoln/support-firecloud/sf- image, but without a tag
    # set the tag to the version of SF
    if [[ ${SF_DOCKER_CI_IMAGE} =~ ^docker.pkg.github.com/rokmoln/support-firecloud/sf- ]] && \
        [[ ! "${SF_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(
            cat ${SUPPORT_FIRECLOUD_DIR}/package.json | ${SUPPORT_FIRECLOUD_DIR}/bin/ -r ".version")
        SF_DOCKER_CI_IMAGE="${SF_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi

    echo "${SF_DOCKER_CI_IMAGE}"
}
