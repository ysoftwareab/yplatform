/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {
  artifactsStep,
  checkoutStep,
  ciShStepsDeploy,
  env: commonEnv
} = require('./main-common');

let {
  matrixContainer
} = require('./main-matrix');

let env = {
  ...commonEnv,
  DOCKER_USERNAME: '${{ secrets.DOCKER_USERNAME }}',
  DOCKER_TOKEN: '${{ secrets.DOCKER_TOKEN }}',
  GITHUB_MATRIX_CONTAINER: '${{ matrix.container }}',
  GITHUB_MATRIX_SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}'
};

// -----------------------------------------------------------------------------

let jobs = {};

let makeJobs = function(matrixContainer, nameSuffix) {
  matrixContainer = _.isArray(matrixContainer) ? matrixContainer : [
    matrixContainer
  ];

  let name = 'deployc-${{ matrix.sf_ci_brew_install }}-${{ matrix.container }}';
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
    name,
    'runs-on': 'ubuntu-latest',
    env: {
      ...env,
      GITHUB_JOB_NAME: name
    },
    steps: [
      checkoutStep,
      ...ciShStepsDeploy,
      _.merge({}, artifactsStep, {
        with: {
          name
        }
      })
    ]
  };
};

_.forEach(matrixContainer, makeJobs);

module.exports = jobs;
