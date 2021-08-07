let {
  env,
  checkoutStep,
  ciShStepsDeploy
} = require('./main-common');

let matrixContainerDeploy = [
  'sf-arch-0',
  'sf-alpine-3.11.7',
  'sf-centos-8',
  'sf-debian-9',
  'sf-debian-10',
  'sf-ubuntu-16.04',
  'sf-ubuntu-18.04',
  'sf-ubuntu-20.04'
];

// -----------------------------------------------------------------------------

let jobs = {};

jobs['deploy-container-minimal'] = {
  if: 'startsWith(github.ref, "refs/tags/")',
  needs: 'main-container',
  strategy: {
    'fail-fast': false,
    matrix: {
      container: matrixContainerDeploy,
      sf_ci_brew_install: [
        'minimal'
      ]
    }
  },
  name: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
  'runs-on': 'ubuntu-latest',
  env: {
    ...env,
    DOCKER_USERNAME: '${{ secrets.DOCKER_USERNAME }}',
    DOCKER_TOKEN: '${{ secrets.DOCKER_TOKEN }}',
    GITHUB_JOB_NAME: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    GITHUB_MATRIX_CONTAINER: '${{ matrix.container }}',
    GITHUB_MATRIX_SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}'
  },
  steps: [
    checkoutStep,
    ...ciShStepsDeploy
  ]
};

jobs['deploy-container-common'] = {
  if: 'startsWith(github.ref, "refs/tags/")',
  needs: 'deploy-container-minimal',
  strategy: {
    'fail-fast': false,
    matrix: {
      container: matrixContainerDeploy,
      sf_ci_brew_install: [
        'common'
      ]
    }
  },
  name: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
  'runs-on': 'ubuntu-latest',
  env: {
    ...env,
    DOCKER_USERNAME: '${{ secrets.DOCKER_USERNAME }}',
    DOCKER_TOKEN: '${{ secrets.DOCKER_TOKEN }}',
    GITHUB_JOB_NAME: 'deployc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    GITHUB_MATRIX_CONTAINER: '${{ matrix.container }}',
    GITHUB_MATRIX_SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}'
  },
  steps: [
    checkoutStep,
    ...ciShStepsDeploy
  ]
};

jobs['main-container'] = {
  'timeout-minutes': 30,
  strategy: {
    'fail-fast': false,
    matrix: {
      container: matrixContainerDeploy,
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
    DOCKER_USERNAME: '${{ secrets.DOCKER_USERNAME }}',
    DOCKER_TOKEN: '${{ secrets.DOCKER_TOKEN }}',
    GITHUB_JOB_NAME: 'mainc-${{ matrix.container }}-${{ matrix.sf_ci_brew_install }}',
    GITHUB_MATRIX_CONTAINER: '${{ matrix.container }}',
    GITHUB_MATRIX_SF_CI_BREW_INSTALL: '${{ matrix.sf_ci_brew_install }}',
    SF_DEPLOY_DRYRUN: true
  },
  steps: [
    checkoutStep,
    ...ciShStepsDeploy
  ]
};

module.exports = jobs;
