/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {
  WSLENV,
  artifactsStep,
  cacheHomebrewLinuxSteps,
  checkoutStep,
  ciShSteps,
  env: commonEnv,
  wslSteps
} = require('./main-common');

let {
  jobRefs,
  matrixOs
} = require('./main-matrix');

let env = {
  ...commonEnv
};

// -----------------------------------------------------------------------------

let jobs = {};

let makeJobsWindows = function(matrixOs, nameSuffix) {
  let name = 'main-${{ matrix.yp_ci_brew_install }}-${{ matrix.os }}';
  jobs[`main-${nameSuffix}`] = {
    needs: jobRefs.smokeMain,
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

  let name = 'main-${{ matrix.yp_ci_brew_install }}-${{ matrix.os }}';
  jobs[`main-${nameSuffix}`] = {
    needs: _.includes(jobRefs.smokeMain, `main-${nameSuffix}`) ? [] : jobRefs.smokeMain,
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
      ...cacheHomebrewLinuxSteps,
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
