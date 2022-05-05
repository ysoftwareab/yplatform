/* eslint-disable no-template-curly-in-string */

let fs = require('fs');
let _ = require('lodash-firecloud');

let artifacts = (function() {
  // convert from https://git-scm.com/docs/gitignore format
  // to https://github.com/actions/toolkit/tree/main/packages/glob format
  let artifacts = fs.readFileSync(`${__dirname}/../../.artifacts`, 'utf8');
  artifacts = _.split(artifacts, '\n');
  artifacts = _.reduce(artifacts, function(artifacts, artifact) {
    if (/^#/.test(artifact)) {
      // ignore comments
      return artifacts;
    }
    if (/^\s*$/.test(artifact)) {
      // ignore empty lines
      return artifacts;
    }
    let maybeNegation = '';
    if (/^!$/.test(artifact)) {
      maybeNegation = '!';
      artifact = _.replace(artifact, /^!/, '');
    }
    if (/^\//.test(artifact)) {
      artifact = _.replace(artifact, /^\//, '');
      artifacts.push(`${maybeNegation}${artifact}`);
      return artifacts;
    }
    artifact = `**/${artifact}`;
    artifact = _.replace(artifact, /^\*\*\/\*\//, '**/');
    artifact = _.replace(artifact, /^\*\*\/\*\*\//, '**/');
    artifacts.push(`${maybeNegation}${artifact}`);
    return artifacts;
  }, []);
  // sync with ci/after-script.sh
  artifacts.push('log.sh-session');
  artifacts = _.join(artifacts, '\n');
  return artifacts;
})();

let artifactsStep = {
  name: 'Upload Artifacts',
  uses: 'actions/upload-artifact@v2',
  with: {
    name: undefined, // need to overwrite
    path: artifacts,
    'retention-days': 7
  }
};

// -----------------------------------------------------------------------------

let githubCheckout = fs.readFileSync(`${__dirname}/../../bin/github-checkout`, 'utf8');

let checkoutStep = {
  name: 'yplatform/bin/github-checkout',
  shell: 'bash',
  run: [
    'set -x',
    githubCheckout
  ].join('\n')
};

// -----------------------------------------------------------------------------

let ciShSteps = [];

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh before_install'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh install'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh before_script'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh script'
});

ciShSteps.push({
  if: 'failure()',
  shell: 'bash',
  run: './.ci.sh after_failure || true'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh after_success || true'
});

ciShSteps.push({
  if: 'always()',
  shell: 'bash',
  run: './.ci.sh after_script || true'
});

ciShSteps.push({
  if: 'always()',
  shell: 'bash',
  env: {
    SLACK_WEBHOOK: '${{ secrets.SLACK_WEBHOOK }}',
    SLACK_CHANNEL: 'cloud-ci',
    YP_CI_STATUS: '${{ job.status }}'
  },
  run: './.ci.sh notifications || true'
});

// -----------------------------------------------------------------------------

let ciShStepsDeploy = [];

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh before_deploy'
});

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh deploy'
});

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh after_deploy || true'
});

// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------

let env = {
  GITHUB_TOKEN: '${{ secrets.GITHUB_TOKEN }}',
  YP_LOG_BOOTSTRAP: true,
  YP_PRINTENV_BOOTSTRAP: '${{ secrets.YP_PRINTENV_BOOTSTRAP }}',
  YP_TRANSCRYPT_PASSWORD: '${{ secrets.YP_TRANSCRYPT_PASSWORD }}',
  V: '${{ secrets.V }}'
};

// -----------------------------------------------------------------------------

// ci
let WSLENV = 'CI:V';
// yplatform
WSLENV = `${WSLENV}:YP_LOG_BOOTSTRAP:YP_PRINTENV_BOOTSTRAP`;
// github
WSLENV = `${WSLENV}:GH_TOKEN:GH_USERNAME`;
// transcrypt
WSLENV = `${WSLENV}:YP_TRANSCRYPT_PASSWORD`;
// slack
WSLENV = `${WSLENV}:SLACK_WEBHOOK:SLACK_CHANNEL`;
// custom
WSLENV = `${WSLENV}:YP_CI_BREW_INSTALL:YP_CI_STATUS`;

let wslSteps = [];

wslSteps.push({
  name: 'Set up WSLENV',
  shell: 'bash',
  run: _.join([
    'set -x',
    'GITHUB_WSLENV="$(printenv | grep "^GITHUB" | cut -d"=" -f1 | sort | \\',
    'sed "s|^GITHUB_ENV\\$|GITHUB_ENV/p|" | \\',
    'sed "s|^GITHUB_EVENT_PATH\\$|GITHUB_EVENT_PATH/p|" | \\',
    'sed "s|^GITHUB_PATH\\$|GITHUB_PATH/p|" | \\',
    'sed "s|^GITHUB_WORKSPACE\\$|GITHUB_WORKSPACE/p|" | \\',
    'tr "\\n" ":")"',
    'echo "WSLENV=${WSLENV:-}:${GITHUB_WSLENV}" >> ${GITHUB_ENV}'
  ], '\n')
});

wslSteps.push({
  name: 'Install WSL Distribution',
  uses: 'Vampire/setup-wsl@v1',
  with: {
    distribution: 'Ubuntu-20.04',
    update: 'false'
  }
});

wslSteps.push({
  name: 'Set up WSL Distribution',
  shell: 'bash',
  run: _.join([
    'set -x',
    'wsl bash -c "cat /etc/os-release"',
    'wsl bash -c "sudo addgroup --gid 2000 ${WSLGROUP}"',
    'wsl bash -c "sudo adduser --uid 2000 --ingroup ${WSLGROUP} --home /home/${WSLUSER}' +
    ' --shell /bin/bash --disabled-password --gecos \\"Linux user\\" ${WSLUSER}"',
    'wsl bash -c "sudo adduser ${WSLUSER} sudo"',
    'wsl bash -c "sudo echo \\"${WSLUSER} ALL=(ALL) NOPASSWD:ALL\\" >> /etc/sudoers"',
    '# Use wsl.conf to fix error: chmod on .git/config.lock failed: Operation not permitted',
    '# See https://gist.github.com/shakahl/8b6c969768b3a54506c0fc4905d729a0',
    'wsl bash -c "sudo cp priv/wsl.conf /etc/wsl.conf && sudo chmod 0644 /etc/wsl.conf"',
    // Need to shutdown wsl, in order to apply the wsl.conf config
    // https://github.com/MicrosoftDocs/WSL/blob/master/WSL/wsl-config.md
    'wsl --shutdown || true'
  ], '\n')
});

module.exports = {
  WSLENV,
  artifactsStep,
  checkoutStep,
  ciShSteps,
  ciShStepsDeploy,
  dockerBuildxSteps,
  env,
  wslSteps
};
