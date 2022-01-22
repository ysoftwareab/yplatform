/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {artifactsStep} = require('./common-step-artifacts');
let {checkoutStep} = require('./common-step-checkout');
let {ciShSteps} = require('./common-steps');
let {env: commonEnv} = require('./common-env');
let {matrixOs} = require('./common-matrix-os');
let {
  WSLENV,
  wslSteps
} = require('./common-wsl');

let env = {
  ...commonEnv
};

// -----------------------------------------------------------------------------

let jobs = {};

let makeJobsWindows = function(matrixOs, nameSuffix) {
  let name = 'main-${{ matrix.yp_ci_brew_install }}-${{ matrix.os }}';
  jobs[`main-${nameSuffix}`] = {
    needs: [
      'main-ubuntu',
      'main-macos'
    ],
    'timeout-minutes': 60,
    strategy: {
      'fail-fast': false,
      matrix: {
        os: matrixOs,
        yp_ci_brew_install: [
          'minimal'
        ]
      }
    },
    name,
    'runs-on': '${{ matrix.os }}',
    env: {
      ...env,
      GITHUB_JOB_NAME: name,
      YP_CI_BREW_INSTALL: '${{ matrix.yp_ci_brew_install }}',
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

  let needs = [];
  switch (nameSuffix) {
  case 'macos':
    needs = [
      'main-ubuntu'
    ];
    break;
  default:
    break;
  }

  let name = 'main-${{ matrix.yp_ci_brew_install }}-${{ matrix.os }}';
  jobs[`main-${nameSuffix}`] = {
    needs,
    // some macos agents simply have lower I/O rates and take longer
    // see https://github.com/actions/virtual-environments/issues/3885
    // see https://github.com/actions/virtual-environments/issues/2707#issuecomment-896569343
    'timeout-minutes': nameSuffix === 'macos' ? 60 : 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        os: matrixOs,
        yp_ci_brew_install: [
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
      YP_CI_BREW_INSTALL: '${{ matrix.yp_ci_brew_install }}'
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
