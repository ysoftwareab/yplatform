#!/usr/bin/env bash
set -euo pipefail

# SYSTEM
cd ${SUPPORT_FIRECLOUD_DIR}
chown -R root:root .
git config --replace-all url."https://github.com/".insteadOf "git@github.com:"
git config --add url."https://github.com/".insteadOf "git://github.com/"

export SF_DOCKER=true
sudo --preserve-env -H -u ${UNAME} ./bootstrap/linux/bootstrap
unset SF_DOCKER

source ${SUPPORT_FIRECLOUD_DIR}/sh/env.inc.sh
make BUILD
make VERSION

git rev-parse HEAD > /support-firecloud.bootstrapped

# USER
cat <<EOF >> /home/${UNAME}/.bash_aliases
source /support-firecloud/sh/dev.inc.sh
EOF
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.bash_aliases

cat <<EOF >> /home/${UNAME}/.gitconfig
[include]
    path = /support-firecloud/gitconfig/dot.gitconfig
EOF
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.gitconfig

ln -s /support-firecloud/gitconfig/dot.gitattributes_global /home/${UNAME}/.gitattributes_global
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.gitattributes_global

ln -s /support-firecloud/gitconfig/dot.gitignore_global /home/${UNAME}/.gitignore_global
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.gitignore_global

mkdir -p /home/${UNAME}/.ssh
chmod 700 /home/${UNAME}/.ssh
echo -e "Host github.com\n  StrictHostKeyChecking yes\n  CheckHostIP no" >/home/${UNAME}/.ssh/config
chmod 600 /home/${UNAME}/.ssh/config
echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >/home/${UNAME}/.ssh/known_hosts
chmod 600 /home/${UNAME}/.ssh/known_hosts

touch /home/${UNAME}/.sudo_as_admin_successful
chown ${UID_INDEX}:${GID_INDEX} /home/${UNAME}/.sudo_as_admin_successful
