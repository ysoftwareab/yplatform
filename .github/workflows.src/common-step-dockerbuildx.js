/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let dockerBuildxSteps = [];

dockerBuildxSteps.push({
  name: 'Set up QEMU',
  uses: 'docker/setup-qemu-action@v1'
});

dockerBuildxSteps.push({
  name: 'Set up Docker Buildx',
  id: 'buildx',
  uses: 'docker/setup-buildx-action@v1',
  with: {
    'buildkitd-flags': '--debug'
  }
});

module.exports = {
  dockerBuildxSteps
};
