#!/usr/bin/env bash
set -euo pipefail

cd ${YP_DIR}

chown -R root:root .

git reset --hard HEAD
git clean -xdf .

# git config --replace-all url."https://github.com/".insteadOf "git@github.com:"
# git config --add url."https://github.com/".insteadOf "git://github.com/"

chown -R ${UNAME}:${GNAME} .
export YP_DOCKER=true
sudo --preserve-env -H -u ${UNAME} ./bootstrap/bootstrap
unset YP_DOCKER
chown -R root:root .

source ${YP_DIR}/sh/env.inc.sh
make BUILD
make VERSION

git rev-parse HEAD > /yplatform.bootstrapped

# if /usr/local/bin/git doesn't exist and if git was installed via homebrew
# enable homebrew's newer git in github actions by actions/checkout,
# or else no history/submodules/etc with REST API checkouts
[[ -e /usr/local/bin/git ]] || \
    [[ ! -e /home/linuxbrew/.linuxbrew/bin/git ]] || \
    ln -sfn /home/linuxbrew/.linuxbrew/bin/git /usr/local/bin/git

[[ -e /etc/wsl.conf ]] || {
    echo_do "Generating /etc/wsl.conf..."
    {
        cat ${YP_DIR}/priv/wsl.conf | \
            sed "s/uid=2000/uid=${UID_INDEX}/" | \
            sed "s/gid=2000/gid=${GID_INDEX}/"
        echo
        echo "[user]"
        echo "default=${UNAME}"
    } | sudo tee -a /etc/wsl.conf
    echo_done
}
