/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let {artifactsStep} = require('./common-step-artifacts');
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

let matrixContainerWithSmoke = _.clone(matrixContainer);
matrixContainerWithSmoke.smoke = [
  'yp-ubuntu-20.04'
];
_.forEach(matrixContainerWithSmoke, function(_os, group) {
  if (group === 'smoke') {
    return;
  }
  matrixContainerWithSmoke[group] = _.without(matrixContainerWithSmoke[group], ...matrixContainerWithSmoke.smoke);
});

let jobs = {};

let makeJobs = function(matrixContainer, nameSuffix) {
  matrixContainer = _.isArray(matrixContainer) ? matrixContainer : [
    matrixContainer
  ];

  let needs = [];
  switch (nameSuffix) {
  case 'smoke':
    break;
  default:
    needs = [
      'mainc-minimal-smoke',
      'mainc-common-smoke'
    ];
    break;
  }

  // name should be the exact docker image name as defined in dockerfiles/util/build:DOCKER_IMAGE_NAME
  let name = '${{ matrix.container }}-${{ matrix.yp_ci_brew_install }}';
  jobs[`mainc-minimal-${nameSuffix}`] = {
    needs,
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
      GITHUB_JOB_NAME: name,
      YP_DEPLOY_DRYRUN: true
    },
    steps: [
      checkoutStep,
      ...dockerBuildxSteps,
      ...ciShStepsDeploy,
      _.merge({}, artifactsStep, {
        with: {
          name
        }
      })
    ]
  };
};

_.forEach(matrixContainerWithSmoke, makeJobs);

module.exports = jobs;
