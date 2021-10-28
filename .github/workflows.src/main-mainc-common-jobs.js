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
  GITHUB_MATRIX_YP_CI_BREW_INSTALL: '${{ matrix.yp_ci_brew_install }}'
};

// -----------------------------------------------------------------------------

let jobs = {};

let makeJobs = function(matrixContainer, nameSuffix) {
  matrixContainer = _.isArray(matrixContainer) ? matrixContainer : [
    matrixContainer
  ];

  // name should be the exact docker image name as defined in dockerfiles/util/build:DOCKER_IMAGE_NAME
  let name = '${{ matrix.container }}-${{ matrix.yp_ci_brew_install }}';
  jobs[`mainc-common-${nameSuffix}`] = {
    needs: `mainc-minimal-${nameSuffix}`,
    'timeout-minutes': 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        container: matrixContainer,
        yp_ci_brew_install: [
          'common'
        ]
      }
    },
    name,
    'runs-on': 'ubuntu-latest',
    env: {
      ...env,
      GITHUB_JOB_NAME: name,
      YP_DEPLOY_DRYRUN: true
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
