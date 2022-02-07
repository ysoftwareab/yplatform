#!/usr/bin/env node

let _ = require('lodash-firecloud');
let yaml = require('js-yaml');

let vscodeExtensions = require('./.vscode/extensions.json');

// see https://www.gitpod.io/docs/config-gitpod-file

let config = {
  // image: process.env.YP_DOCKER_CI_IMAGE
  // image: 'ubuntu:20.04',
  image: 'ysoftwareab/yp-ubuntu-20.04-common:latest',

  github: {
    prebuilds: {
      master: true,
      branches: false,
      pullRequests: false,
      pullRequestsFromForks: false,
      addCheck: false,
      addComment: false,
      addBadge: true
    }
  },

  vscode: {
    extensions: vscodeExtensions.recommendations
  },

  // NOTE 'make bootstrap' would be nice because
  // the branch's bootstrap might be out of sync with ysoftwareab/yp-ubuntu-20.04-common:latest
  // NOTE 'gp env PATH=$PATH' in order for vscode to find brew executable e.g. shellcheck
  // TODO should also modify the shell's rc file to source dev/inc.sh

  tasks: [{
    // init: _.join([
    //   'source dev/inc.sh',
    //   'make bootstrap'
    // ], '\n'),
    command: _.join([
      'source dev/inc.sh',
      'gp env PATH=$PATH',
      'gp open README.md',
      'make help'
    ], '\n')
  }]
};

if (require.main === module) {
  let ymlConfig = yaml.dump(config);
  // eslint-disable-next-line no-console
  console.log(ymlConfig);
} else {
  module.exports = config;
}
