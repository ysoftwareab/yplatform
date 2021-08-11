/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {
  artifactsStep,
  checkoutStep,
  ciShSteps,
  env: commonEnv,
  matrixOs,
  stage1Jobs
} = require('./main-common');

let env = {
  ...commonEnv
};

// ci
let WSLENV = 'CI:V';
// support-firecloud
WSLENV = `${WSLENV}:SF_LOG_BOOTSTRAP:SF_PRINTENV_BOOTSTRAP`;
// github
WSLENV = `${WSLENV}:GH_TOKEN:GH_USERNAME`;
// transcrypt
WSLENV = `${WSLENV}:SF_TRANSCRYPT_PASSWORD`;
// slack
WSLENV = `${WSLENV}:SLACK_WEBHOOK:SLACK_CHANNEL:CI_STATUS`;
// custom
WSLENV = `${WSLENV}:SF_CI_BREW_INSTALL`;

// -----------------------------------------------------------------------------

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
    'wsl bash -c "sudo cp priv/wsl.conf /etc/wsl.conf && sudo chmod 0644 /etc/wsl.conf"'
  ], '\n')
});

// -----------------------------------------------------------------------------

let jobs = {};

let makeJobsWindows = function(matrixOs, nameSuffix) {
  let name = 'main-${{ matrix.os }}-${{ matrix.sf_ci_brew_install }}';
  jobs[`main-${nameSuffix}`] = {
    needs: stage1Jobs,
    'timeout-minutes': 60,
    strategy: {
      'fail-fast': false,
      matrix: {
        os: matrixOs,
        sf_ci_brew_install: [
          'minimal'
        ]
      }
    },
    name,
    'runs-on': '${{ matrix.os }}',
    env: {
      ...env,
      GITHUB_JOB_NAME: name,
      SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}',
      WSLENV,
      WSLUSER: 'github',
      WSLGROUP: 'github'
    },
    steps: [
      checkoutStep,
      ...wslSteps,
      ...(function() {
        return _.map(ciShSteps, function(step) {
          return {
            ...step,
            run: `bin/wsl-bash -c "${step.run}"`
          };
        });
      })()
      // TODO need to learn how to access paths inside WSL from Windows
      // _.merge({}, artifactsStep, {
      //   with: {
      //     name
      //   }
      // })
    ]
  };
};

let makeJobs = function(matrixOs, nameSuffix) {
  matrixOs = _.isArray(matrixOs) ? matrixOs : [
    matrixOs
  ];

  if (nameSuffix === 'windows') {
    makeJobsWindows(matrixOs, nameSuffix);
    return;
  }

  let name = 'main-${{ matrix.os }}-${{ matrix.sf_ci_brew_install }}';
  jobs[`main-${nameSuffix}`] = {
    needs: _.includes(stage1Jobs, `main-${nameSuffix}`) ? undefined : stage1Jobs,
    // some macos agents simply have a slower I/O rates and take longer
    // see https://github.com/actions/virtual-environments/issues/2707#issuecomment-896569343
    'timeout-minutes': nameSuffix === 'macos' ? 45 : 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        os: matrixOs,
        sf_ci_brew_install: [
          'minimal',
          'dev'
        ]
      }
    },
    name,
    'runs-on': '${{ matrix.os }}',
    env: {
      ...env,
      GITHUB_JOB_NAME: name,
      SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}'
    },
    steps: [
      checkoutStep,
      ...ciShSteps,
      _.merge({}, artifactsStep, {
        with: {
          name
        }
      })
    ]
  };
};

_.forEach(matrixOs, makeJobs);

module.exports = jobs;
