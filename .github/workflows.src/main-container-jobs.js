/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {
  checkoutStep,
  ciShStepsDeploy,
  env: commonEnv,
  matrixContainer,
  stage2Jobs
} = require('./main-common');

let env = {
  ...commonEnv,
  DOCKER_USERNAME: '${{ secrets.DOCKER_USERNAME }}',
  DOCKER_TOKEN: '${{ secrets.DOCKER_TOKEN }}',
  GITHUB_MATRIX_CONTAINER: '${{ matrix.container }}',
  GITHUB_MATRIX_SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}'
};

// -----------------------------------------------------------------------------

let jobs = {};

let makeContainerJobs = function(matrixContainer, nameSuffix) {
  matrixContainer = _.isArray(matrixContainer) ? matrixContainer : [
    matrixContainer
  ];

  jobs[`mainc-${nameSuffix}`] = {
    needs: stage2Jobs,
    'timeout-minutes': 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        container: matrixContainer,
        sf_ci_brew_install: [
          'minimal',
          'common'
        ]
      }
    },
    name: 'mainc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    'runs-on': 'ubuntu-latest',
    env: {
      ...env,
      GITHUB_JOB_NAME: 'mainc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
      SF_DEPLOY_DRYRUN: true
    },
    steps: [
      checkoutStep,
      ...ciShStepsDeploy
    ]
  };

  jobs[`deployc-minimal-${nameSuffix}`] = {
    if: "startsWith(github.ref, 'refs/tags/')",
    needs: `mainc-${nameSuffix}`,
    'timeout-minutes': 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        container: matrixContainer,
        sf_ci_brew_install: [
          'minimal'
        ]
      }
    },
    name: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    'runs-on': 'ubuntu-latest',
    env: {
      ...env,
      GITHUB_JOB_NAME: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}'
    },
    steps: [
      checkoutStep,
      ...ciShStepsDeploy
    ]
  };

  jobs[`deployc-common-${nameSuffix}`] = {
    if: "startsWith(github.ref, 'refs/tags/')",
    needs: `deployc-minimal-${nameSuffix}`,
    'timeout-minutes': 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        container: matrixContainer,
        sf_ci_brew_install: [
          'common'
        ]
      }
    },
    name: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    'runs-on': 'ubuntu-latest',
    env: {
      ...env,
      GITHUB_JOB_NAME: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}'
    },
    steps: [
      checkoutStep,
      ...ciShStepsDeploy
    ]
  };
};

_.forEach(matrixContainer, makeContainerJobs);

module.exports = jobs;
