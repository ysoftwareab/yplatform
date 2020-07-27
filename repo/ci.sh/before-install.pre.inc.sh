#!/usr/bin/env bash

function sf_run_docker_ci_image() {
    local SF_DOCKER_CI_IMAGE=${1}
    local MOUNT_DIR=${2:-${PWD}}
    local CONTAINER_NAME=${3:-sf-docker-ci}

    echo_do "Spinning up Docker for ${SF_DOCKER_CI_IMAGE}..."

    echo_do "Pulling ${SF_DOCKER_CI_IMAGE} image..."
    exe docker pull ${SF_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Running the ${CONTAINER_NAME} container, proxying relevant env vars and mounting ${MOUNT_DIR} folder..."
    exe docker run -d -it --rm \
        --name ${CONTAINER_NAME} \
        --hostname ${CONTAINER_NAME} \
        --add-host ${CONTAINER_NAME}:127.0.0.1 \
        --env CI=true \
        --env USER=$(whoami) \
        --env-file <(${SUPPORT_FIRECLOUD_DIR}/bin/travis-get-env-vars) \
        --volume ${MOUNT_DIR}:${MOUNT_DIR} \
        --privileged \
        --network=host \
        --ipc=host \
        ${SF_DOCKER_CI_IMAGE}
    echo_done

    echo_do "Instrumenting the ${CONTAINER_NAME} container..."
    exe docker exec -it -u root ${CONTAINER_NAME} \
        touch /support-firecloud.docker-ci

    # create same groups (and gids) that the 'travis' user belongs to inside the docker container
    # NOTE groups can have whitespace, thus cannot use a regular for loop,
    # and instead using a while loop with \0 delimiters
    while IFS= read -u3 -rd '' GROUP_NAME; do
        # NOTE using python instead of getent for compatibility with MacOS
        exe docker exec -it -u root ${CONTAINER_NAME} \
            addgroup \
            --force-badname \
            --gid $(python -c "import grp; print(grp.getgrnam(\"${GROUP_NAME}\").gr_gid)") \
            "${GROUP_NAME}" || true;
    done 3< <(id -G --name --zero)

    # create same user (and uid) that the 'travis' user has inside the docker container
    local EFFECTIVE_GROUP_NAME="$(id -g --name)"
    exe docker exec -it -u root ${CONTAINER_NAME} \
        adduser \
        --force-badname \
        --uid $(id -u) \
        --ingroup "${EFFECTIVE_GROUP_NAME}" \
        --home ${HOME} \
        --shell /bin/sh \
        --disabled-password \
        --gecos "" \
        "$(id -u --name)"

    # add the 'travis' user to the groups inside the docker container
    # NOTE groups can have whitespace, thus cannot use a regular for loop,
    # and instead using a while loop with \0 delimiters
    while IFS= read -u3 -rd '' GROUP_NAME; do
        exe docker exec -it -u root ${CONTAINER_NAME} \
            adduser \
            --force-badname \
            "$(id -u --name)" \
            "${GROUP_NAME}" || true;
    done 3< <(id -G --name --zero)

    exe docker exec -it -u root ${CONTAINER_NAME} \
        adduser \
        --force-badname \
        "$(id -u --name)" \
        sudo || true;

    # if ${MOUNT_DIR} is under ${HOME}, make sure ${HOME} is writeable
    # to allow for special folders/files e.g. ~/.cache to be accessible for writing
    echo_do "Taking ownership over ${HOME}..."
    exe docker exec -it -u root ${CONTAINER_NAME} \
        chown $(id -u):$(id -g) ${HOME}
    echo_done

    echo_done # "Instrumenting the ${CONTAINER_NAME} container..."

    echo_done # "Spinning up Docker for ${SF_DOCKER_CI_IMAGE}..."
}


function sf_get_docker_ci_image() {
    if [[ -z "${SF_DOCKER_CI_IMAGE:-}" ]]; then
        local RELEASE_ID
        local RELEASE_VERSION_CODENAME
        [[ ! -f /etc/os-release ]] || {
            RELEASE_ID=$(source /etc/os-release && echo ${ID})
            RELEASE_VERSION_CODENAME=$(source /etc/os-release && echo ${VERSION_CODENAME})
        }
        SF_DOCKER_CI_IMAGE=rokmoln/sf-${RELEASE_ID:-ubuntu}-${RELEASE_VERSION_CODENAME:-xenial}-minimal
    fi
    # if given a rokmoln/sf- image, but without a tag,
    # set the tag to the version of SF
    if [[ ${SF_DOCKER_CI_IMAGE} =~ ^rokmoln/sf- ]] && \
        [[ ! "${SF_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(cat ${SUPPORT_FIRECLOUD_DIR}/package.json | jq -r ".version")
        SF_DOCKER_CI_IMAGE="${SF_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi
    # if given a docker.pkg.github.com/rokmoln/support-firecloud/sf- image, but without a tag
    # set the tag to the version of SF
    if [[ ${SF_DOCKER_CI_IMAGE} =~ ^docker.pkg.github.com/rokmoln/support-firecloud/sf- ]] && \
        [[ ! "${SF_DOCKER_CI_IMAGE}" =~ /:/ ]]; then
        local DOCKER_IMAGE_TAG=$(cat ${SUPPORT_FIRECLOUD_DIR}/package.json | jq -r ".version")
        SF_DOCKER_CI_IMAGE="${SF_DOCKER_CI_IMAGE}:${DOCKER_IMAGE_TAG}"
    fi

    echo "${SF_DOCKER_CI_IMAGE}"
}


function sf_run_docker_ci_in_travis() {
    (
        source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util.inc.sh
        apt_update
        apt_install expect # install unbuffer
        apt_install pv
    )

    sf_run_docker_ci_image "$(sf_get_docker_ci_image)" "${HOME}" sf-docker-ci-travis
}


function sf_enable_travis_swap() {
    [[ "${TRAVIS:-}" = "true" ]] || return 0
    [[ "${OS_SHORT:-}" = "linux" ]] || return 0
    [[ -z "${WSLENV:-}" ]] || return 0
    [[ ! -f /support-firecloud.docker-ci ]] || return 0

    local MEM_MIB=$(free -m | grep Mem | sed "s/ \+/ /g" | cut -d" " -f2)
    local MEM_GIB=$(( (${MEM_MIB}*2 + 1023) / 1024 ))
    local MEM_GIB_SWAP=/mnt/${MEM_GIB}GiB.swap
    echo_do "Enabling swap..."
    cat /proc/swaps
    sudo fallocate -l ${MEM_GIB}g ${MEM_GIB_SWAP}
    sudo chmod 600 ${MEM_GIB_SWAP}
    sudo mkswap ${MEM_GIB_SWAP}
    sudo swapon ${MEM_GIB_SWAP}
    sudo sysctl vm.swappiness=10
    echo_done
}


function sf_disable_travis_swap() {
    [[ "${TRAVIS:-}" = "true" ]] || return 0
    [[ "${OS_SHORT:-}" = "linux" ]] || return 0
    [[ -z "${WSLENV:-}" ]] || return 0
    [[ ! -f /support-firecloud.docker-ci ]] || return 0

    local MEM_MIB=$(free -m | grep Mem | sed "s/ \+/ /g" | cut -d" " -f2)
    local MEM_GIB=$(( (${MEM_MIB}*2 + 1023) / 1024 ))
    local MEM_GIB_SWAP=/mnt/${MEM_GIB}GiB.swap
    [[ -e ${MEM_GIB_SWAP} ]] || {
        echo_skip "Disabling swap..."
        return 0
    }
    echo_do "Disabling swap..."
    sudo swapoff ${MEM_GIB_SWAP}
    sudo rm ${MEM_GIB_SWAP}
    echo_done
}
