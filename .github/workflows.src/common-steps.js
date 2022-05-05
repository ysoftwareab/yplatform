/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let ciShSteps = [];

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh before_install'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh install'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh before_script'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh script'
});

ciShSteps.push({
  if: 'failure()',
  shell: 'bash',
  run: './.ci.sh after_failure || true'
});

ciShSteps.push({
  shell: 'bash',
  run: './.ci.sh after_success || true'
});

ciShSteps.push({
  if: 'always()',
  shell: 'bash',
  run: './.ci.sh after_script || true'
});

ciShSteps.push({
  if: 'always()',
  shell: 'bash',
  env: {
    SLACK_WEBHOOK: '${{ secrets.SLACK_WEBHOOK }}',
    SLACK_CHANNEL: 'cloud-ci',
    YP_CI_STATUS: '${{ job.status }}'
  },
  run: './.ci.sh notifications || true'
});

// -----------------------------------------------------------------------------

let ciShStepsDeploy = [];

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh before_deploy'
});

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh deploy'
});

ciShStepsDeploy.push({
  shell: 'bash',
  run: './.ci.sh after_deploy || true'
});

module.exports = {
  ciShSteps,
  ciShStepsDeploy
};
