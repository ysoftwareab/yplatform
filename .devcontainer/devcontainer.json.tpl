#!/usr/bin/env node

// TODO prebuild https://code.visualstudio.com/docs/remote/devcontainer-cli#_building-a-dev-container-image

let _ = require('lodash-firecloud');
let path = require('path');

let name = `yp-docker-vscode-${path.basename(path.dirname(__dirname))}`;
let containerUser = 'yp';
// eslint-disable-next-line no-template-curly-in-string
let workspaceFolder = '${localWorkspaceFolder}';

let vscodeExtensions = require('../.vscode/extensions.json');

// For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:
// https://github.com/microsoft/vscode-dev-containers/tree/v0.217.1/containers/docker-existing-dockerfile

let config = {
  name,

  // image: process.env.YP_DOCKER_CI_IMAGE
  // image: 'ubuntu:20.04',
  image: 'ysoftwareab/yp-ubuntu-20.04-common:latest',

  runArgs: [
    // sync with ci/util/docker-ci.inc.sh
    '--platform linux/amd64',
    '--privileged',
    `--name ${name}`,
    `--hostname ${name}`,
    `--add-host ${name}:127.0.0.1`,
    '--network=host',
    '--ipc=host',
    // '--volume "${MOUNT_DIR}:${MOUNT_DIR}:rw"',
    // '--env CI=true',
    `--env USER=${containerUser}`,

    // sync with yplatform/build.mk/core.misc.docker-ci.mk
    '--env YP_SKIP_SUDO_BOOTSTRAP=true',
    '--env YP_SKIP_BREW_BOOTSTRAP=true'
  ],

  // https://code.visualstudio.com/remote/advancedcontainers/change-default-source-mount
  workspaceMount: `source=${workspaceFolder},target=${workspaceFolder},type=bind`,
  workspaceFolder,

  postCreateCommand: [
    'make bootstrap'
  ],

  containerUser,

  mounts: [
    // see https://code.visualstudio.com/docs/remote/troubleshooting#_persisting-user-profile
    // persist user profile
    'source=profile,target=/root,type=volume',
    'target=/root/.vscode-server,type=volume',
    // see https://code.visualstudio.com/remote/advancedcontainers/avoid-extension-reinstalls
    // persist extensions
    'source=unique-vol-name-here,target=/root/.vscode-server/extensions,type=volume',
    'source=unique-vol-name-here-insiders,target=/root/.vscode-server-insiders/extensions,type=volume'
  ],

  // ---------------------------------------------------------------------------

  extensions: [
    ...vscodeExtensions.recommendations,
    'mutantdino.resourcemonitor'
  ],

  settings: {
    'terminal.integrated.shell.linux': '/usr/bin/bash'
  },

  // https://github.com/microsoft/vscode-dev-containers/tree/main/script-library/docs
  features: {}
};

if (require.main === module) {
  // eslint-disable-next-line no-console, no-null/no-null
  console.log(JSON.stringify(config, null, 2));
} else {
  module.exports = config;
}
