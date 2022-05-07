#!/usr/bin/env bash
set -euo pipefail

function yp_enable_travis_swap() {
    [[ "${YP_CI_PLATFROM:-}" = "travis" ]] || return 0
    [[ "${OS_SHORT:-}" = "linux" ]] || return 0
    ! ${YP_DIR}/bin/is-wsl || return 0
    [[ ! -f /yplatform.docker-ci ]] || return 0

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


function yp_disable_travis_swap() {
    [[ "${YP_CI_PLATFROM:-}" = "travis" ]] || return 0
    [[ "${OS_SHORT:-}" = "linux" ]] || return 0
    ! ${YP_DIR}/bin/is-wsl || return 0
    [[ ! -f /yplatform.docker-ci ]] || return 0

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
