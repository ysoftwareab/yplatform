/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-y');

let {
  getArtifacts,
  artifactsStep
} = require('./common-step-artifacts');
let {checkoutStep} = require('./common-step-checkout');
let {ciShStepsDeploy} = require('./common-steps');
let {dockerBuildxSteps} = require('./common-step-dockerbuildx');
let {env: commonEnv} = require('./common-env');
let {matrixContainer} = require('./common-matrix-container');

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

  if (_.isEmpty(matrixContainer)) {
    return;
  }

  let name = 'deployc-${{ matrix.container }}-${{ matrix.yp_ci_brew_install }}';
  jobs[`deployc-${nameSuffix}-minimal`] = {
    needs: [],
    'timeout-minutes': 30,
    strategy: {
      'fail-fast': false,
      matrix: {
        container: matrixContainer,
        yp_ci_brew_install: [
          'minimal'
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
      ...dockerBuildxSteps,
      ...ciShStepsDeploy,
      _.merge({}, artifactsStep, {
        with: {
          name,
          path: getArtifacts(`${__dirname}/../../.artifacts`)
        }
      })
    ]
  };
};

_.forEach(matrixContainer, makeJobs);

module.exports = jobs;
