/* eslint-disable no-template-curly-in-string */

let fs = require('fs');

let githubCheckout = fs.readFileSync(`${__dirname}/../../bin/github-checkout`, 'utf8');

let env = {
  GITHUB_TOKEN: '${{ secrets.GITHUB_TOKEN }}',
  SF_LOG_BOOTSTRAP: true,
  SF_PRINTENV_BOOTSTRAP: '${{ secrets.SF_PRINTENV_BOOTSTRAP }}',
  SF_TRANSCRYPT_PASSWORD: '${{ secrets.SF_TRANSCRYPT_PASSWORD }}',
  V: '${{ secrets.V }}'
};

let checkoutStep = {
  name: 'support-firecloud/bin/github-checkout',
  shell: 'bash',
  run: [
    'set -x',
    githubCheckout
  ].join('\n')
};

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
    CI_STATUS: '${{ job.status }}'
  },
  run: './.ci.sh notifications || true'
});

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
  env,
  checkoutStep,
  ciShSteps,
  ciShStepsDeploy
};
