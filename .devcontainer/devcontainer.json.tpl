#!/usr/bin/env node

// TODO prebuild https://code.visualstudio.com/docs/remote/devcontainer-cli#_building-a-dev-container-image

let _ = require('lodash-firecloud');
let fs = require('fs');

let vscodeExtensions = fs.readFileSync(`${__dirname}/../.vscode/extensions.json`);
vscodeExtensions = JSON.parse(vscodeExtensions);

// For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:
// https://github.com/microsoft/vscode-dev-containers/tree/v0.217.1/containers/docker-existing-dockerfile

let config = {
  name: 'yplatform',

  // image: process.env.YP_DOCKER_CI_IMAGE
  // image: 'ubuntu:20.04',
  image: 'ysoftwareab/yp-ubuntu-20.04-common:latest',

  extensions: vscodeExtensions.recommendations,

  settings: {
    'terminal.integrated.shell.linux': '/usr/bin/bash'
  },

  postCreateCommand: [
    'make bootstrap'
  ],

  containerUser: 'yp',

  // Uncomment to connect as a non-root user if you've added one. See https://aka.ms/vscode-remote/containers/non-root.
  // remoteUser: 'vscode"

  // https://github.com/microsoft/vscode-dev-containers/tree/main/script-library/docs
  features: {}
};

// eslint-disable-next-line no-console, no-null/no-null
console.log(JSON.stringify(config, null, 2));
