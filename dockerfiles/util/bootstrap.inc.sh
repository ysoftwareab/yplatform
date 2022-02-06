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
sudo --preserve-env -H -u ${UNAME} ./bootstrap/linux/bootstrap
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
