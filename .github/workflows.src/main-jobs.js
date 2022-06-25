/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {
  getArtifacts,
  artifactsStep
} = require('./common-step-artifacts');
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

let matrixOsWithSmoke = _.clone(matrixOs);
matrixOsWithSmoke.smoke = [
  'ubuntu-20.04',
  'macos-12'
];
_.forEach(matrixOsWithSmoke, function(_os, group) {
  if (group === 'smoke') {
    return;
  }
  matrixOsWithSmoke[group] = _.without(matrixOsWithSmoke[group], ...matrixOsWithSmoke.smoke);
});

let jobs = {};

let makeJobsWindows = function(matrixOs, nameSuffix) {
  let name = 'main-${{ matrix.os }}-${{ matrix.yp_ci_brew_install }}';
  jobs[`main-${nameSuffix}`] = {
    needs: [
      'main-smoke',
      'main-ubuntu',
      'main-macos'
    ],
    'timeout-minutes': 90,
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

  if (_.isEmpty(matrixOs)) {
    return;
  }

  if (nameSuffix === 'windows') {
    makeJobsWindows(matrixOs, nameSuffix);
    return;
  }

  let needs = [];
  switch (nameSuffix) {
  case 'ubuntu':
  case 'macos':
    needs = [
      'main-smoke'
    ];
    break;
  default:
    break;
  }

  let name = 'main-${{ matrix.os }}-${{ matrix.yp_ci_brew_install }}';
  jobs[`main-${nameSuffix}`] = {
    needs,
    // some macos agents simply have lower I/O rates and take longer
    // see https://github.com/actions/virtual-environments/issues/3885
    // see https://github.com/actions/virtual-environments/issues/2707#issuecomment-896569343
    'timeout-minutes': _.includes([
      'smoke',
      'macos'
    ], nameSuffix) ? 60 : 30,
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
      YP_CI_BREW_INSTALL: '${{ matrix.yp_ci_brew_install }}',
      YP_CI_ECHO_EXTERNAL_HONEYCOMB_DATASET: name
    },
    steps: [
      checkoutStep,
      ...ciShSteps,
      _.merge({}, artifactsStep, {
        with: {
          name,
          path: getArtifacts(`${__dirname}/../../.artifacts`)
        }
      })
    ]
  };
};

_.forEach(matrixOsWithSmoke, makeJobs);

module.exports = jobs;
