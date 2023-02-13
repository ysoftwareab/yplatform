#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Docker packages..."

case ${OS_SHORT}-${OS_RELEASE_ID} in
    darwin-*|linux-amzn|linux-arch|linux-centos|linux-rhel)
        brew_install_one_unless docker "docker --version | head -1" "^Docker version \(19\|20\|21\|22\|23\)\."
        brew_install_one_unless docker-compose "docker-compose --version | head -1" \
            "^\(docker-compose version 1\.\|Docker Compose version 2\.\)"
        ;;
    linux-alpine)
        # docker via linuxbrew will throw
        # /bin/ps: unrecognized option: p
        # 5051
        # BusyBox v1.31.1 () multi-call binary.
        # Usage: ps [-o COL1,COL2=HEADER]
        # Show list of processes
        #     -o COL1,COL2=HEADER	Select columns for display
        # [signal SIGSEGV: segmentation violation code=0x1 addr=0x28 pc=0x7efe9b00b6e8]
        # runtime stack:
        # runtime.throw(0x1e45c1c, 0x2a)
        #     runtime/panic.go:1117 +0x72
        # runtime.sigpanic()
        #     runtime/signal_unix.go:718 +0x2e5
        # goroutine 1 [running]:
        # runtime.systemstack_switch()
        #     runtime/asm_amd64.s:339 fp=0xc000072788 sp=0xc000072780 pc=0x46d940
        # runtime.main()
        #     runtime/proc.go:144 +0x89 fp=0xc0000727e0 sp=0xc000072788 pc=0x43b3e9
        # runtime.goexit()
        #     runtime/asm_amd64.s:1371 +0x1 fp=0xc0000727e8 sp=0xc0000727e0 pc=0x46f781

        # BEGIN https://wiki.alpinelinux.org/wiki/Docker#Installation
        apk_install_one docker
        apk_install_one docker-compose
        # ${YP_SUDO} addgroup $(whoami) docker
        # apk_install_one openrc
        # ${YP_SUDO} rc-update add docker boot
        # ${YP_SUDO} service docker start
        # END https://wiki.alpinelinux.org/wiki/Docker#Installation

        exe_and_grep_q "docker --version | head -1" "^Docker version \(19\|20\|21\|22\|23\)\."
        exe_and_grep_q "docker-compose --version | head -1" \
            "^\(docker-compose version 1\.\|Docker Compose version 2\.\)"
        ;;
    linux-debian|linux-ubuntu)
        # docker-compose via linuxbrew will throw 'Illegal instruction' for e.g. 'docker-compose --version'
        # brew_install_one docker
        # brew_install_one docker-compose

        # BEGIN https://docs.docker.com/engine/install/ubuntu/
        for PKG in docker docker-engine docker.io containerd runc; do
            ${YP_SUDO} apt-get remove ${PKG} || true;
        done
        unset PKG

        apt_install_one apt-transport-https
        apt_install_one ca-certificates
        apt_install_one curl
        apt_install_one gnupg-agent
        apt_install_one software-properties-common

        curl -qfsSL https://download.docker.com/linux/${OS_RELEASE_ID}/gpg | ${YP_SUDO} apt-key add -
        ${YP_SUDO} apt-key fingerprint 0EBFCD88
        ${YP_SUDO} add-apt-repository -u \
            "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/${OS_RELEASE_ID} ${OS_RELEASE_VERSION_CODENAME} stable" # editorconfig-checker-disable-line

        apt_install_one containerd.io
        apt_install_one docker-ce
        apt_install_one docker-ce-cli
        # ENV https://docs.docker.com/engine/install/ubuntu/

        # BEGIN https://docs.docker.com/compose/install/
        # FIXME 1.28 uses python@3.9. see https://github.com/docker/compose/issues/8048
        # DOCKER_COMPOSE_LATEST_URL=https://github.com/docker/compose/releases/latest/download
        DOCKER_COMPOSE_LATEST_URL=https://github.com/docker/compose/releases/download/1.27.4
        ${YP_SUDO} curl -qfsSL -o /usr/local/bin/docker-compose \
            "${DOCKER_COMPOSE_LATEST_URL}/docker-compose-$(uname -s)-$(uname -m)"
        ${YP_SUDO} chmod +x /usr/local/bin/docker-compose
        unset DOCKER_COMPOSE_LATEST_URL
        # END https://docs.docker.com/compose/install/

        exe_and_grep_q "docker --version | head -1" "^Docker version \(19\|20\|21\|22\|23\)\."
        exe_and_grep_q "docker-compose --version | head -1" \
            "^\(docker-compose version 1\.\|Docker Compose version 2\.\)"
        ;;
    *)
        echo_err "${OS_SHORT}-${OS_RELEASE_ID} is an unsupported OS for installing Docker."
        exit 1
        ;;
esac

brew_install_one_unless ctop "ctop -v | head -1" "^ctop version 0\."
brew_install_one_unless dive "dive --version | head -1" "^dive 0\."

echo_done
