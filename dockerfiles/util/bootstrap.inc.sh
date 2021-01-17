#!/usr/bin/env bash
set -euo pipefail

cd ${SUPPORT_FIRECLOUD_DIR}

chown -R root:root .

git reset --hard HEAD
git clean -xdf .

git config --replace-all url."https://github.com/".insteadOf "git@github.com:"
git config --add url."https://github.com/".insteadOf "git://github.com/"

chown -R ${UNAME}:${GNAME} .
export SF_DOCKER=true
sudo --preserve-env -H -u ${UNAME} ./bootstrap/linux/bootstrap
unset SF_DOCKER
chown -R root:root .

source ${SUPPORT_FIRECLOUD_DIR}/sh/env.inc.sh
make BUILD
make VERSION

git rev-parse HEAD > /support-firecloud.bootstrapped

# enable newer git in github actions by actions/checkout, or else no history/submodules/etc with REST API checkouts
[[ -e /usr/local/bin/git ]] || ln -s /home/linuxbrew/.linuxbrew/bin/git /usr/local/bin/git
