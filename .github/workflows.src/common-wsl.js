/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

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
  wslSteps
};
