/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let dockerBuildxSteps = [];

dockerBuildxSteps.push({
  name: 'Set up QEMU',
  uses: 'docker/setup-qemu-action@v2'
});

dockerBuildxSteps.push({
  name: 'Set up Docker Buildx',
  id: 'buildx',
  uses: 'docker/setup-buildx-action@v2',
  with: {
    'buildkitd-flags': '--debug'
  }
});

dockerBuildxSteps.push({
  name: 'Set up Docker Buildx: remote ssh for arm64',
  id: 'buildx-arm64-ssh',
  uses: 'shimataro/ssh-key-action@v2',
  with: {
    key: '${{ secrets.DOCKER_AWS_SSH_PRIVATE_KEY }}',
    // fingerprint changes on reboot
    known_hosts: 'unnecessary'
  }
});

dockerBuildxSteps.push({
  name: 'Set up Docker Buildx: remote builder for arm64',
  id: 'buildx-arm64-builder',
  shell: 'bash',
  env: {
    DOCKER_AWS_SSH_SERVER: 'docker-arm64.aws.ysoftware.se'
  },
  run: [
    'set -x',
    // fingerprint server
    'ssh-keyscan -H ${DOCKER_AWS_SSH_SERVER} >> ~/.ssh/known_hosts || exit 0',
    // test ssh connection
    'ssh ${DOCKER_AWS_SSH_SERVER} "exit 0" || exit 0',
    // create context based on local amd64 + remote arm64
    'docker context create aws-docker-arm64 --docker host=ssh://${DOCKER_AWS_SSH_SERVER}',
    'docker buildx create --name localamd64-remotearm64 default --platform linux/amd64',
    'docker buildx create --name localamd64-remotearm64 aws-docker-arm64 --platform linux/arm64 --append',
    'docker buildx use localamd64-remotearm64'
  ].join('\n')
});

module.exports = {
  dockerBuildxSteps
};
