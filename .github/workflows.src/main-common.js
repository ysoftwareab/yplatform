/* eslint-disable no-template-curly-in-string */

let fs = require('fs');
let _ = require('lodash-firecloud');

let artifacts = (function() {
  // convert from https://git-scm.com/docs/gitignore format
  // to https://github.com/actions/toolkit/tree/main/packages/glob format
  let artifacts = fs.readFileSync(`${__dirname}/../../.artifacts`, 'utf8');
  artifacts = _.split(artifacts, '\n');
  artifacts = _.reduce(artifacts, function(artifacts, artifact) {
    if (/^#/.test(artifact)) {
      // ignore comments
      return artifacts;
    }
    if (/^\s*$/.test(artifact)) {
      // ignore empty lines
      return artifacts;
    }
    let maybeNegation = '';
    if (/^!$/.test(artifact)) {
      maybeNegation = '!';
      artifact = _.replace(artifact, /^!/, '');
    }
    if (/^\//.test(artifact)) {
      artifact = _.replace(artifact, /^\//, '');
      artifacts.push(`${maybeNegation}${artifact}`);
      return artifacts;
    }
    artifact = `**/${artifact}`;
    artifact = _.replace(artifact, /^\*\*\/\*\//, '**/');
    artifact = _.replace(artifact, /^\*\*\/\*\*\//, '**/');
    artifacts.push(`${maybeNegation}${artifact}`);
    return artifacts;
  }, []);
  // sync with ci/after-script.sh
  artifacts.push('log.sh-session');
  artifacts = _.join(artifacts, '\n');
  return artifacts;
})();

let githubCheckout = fs.readFileSync(`${__dirname}/../../bin/github-checkout`, 'utf8');

let matrixOs = {
  ubuntu: [
    // deprecated in https://github.com/actions/virtual-environments/issues/3287
    // "ubuntu-16.04",
    'ubuntu-18.04',
    'ubuntu-20.04'
  ],
  macos: [
    'macos-10.15',
    'macos-11.0'
  ],
  windows: [
    'windows-2019'
  ]
};

let matrixContainer = {
  arch: [
    'sf-arch-0'
  ],
  alpine: [
    'sf-alpine-3.11.7'
  ],
  centos: [
    'sf-centos-8'
  ],
  debian: [
    'sf-debian-9',
    'sf-debian-10'
  ],
  ubuntu: [
    'sf-ubuntu-16.04',
    'sf-ubuntu-18.04',
    'sf-ubuntu-20.04'
  ]
};

let stage1Jobs = [
  'main-ubuntu'
];

let stage2Jobs = _.reduce(_.keys(matrixOs), function(needs, nameSuffix) {
  // ignore windows, because it is very very very slow
  if (nameSuffix === 'windows') {
    return needs;
  }
  needs.push(`main-${nameSuffix}`);
  return needs;
}, []);

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

let artifactsStep = {
  name: 'Upload Artifacts',
  uses: 'actions/upload-artifact@v2',
  with: {
    name: undefined, // need to overwrite
    path: artifacts,
    'retention-days': 7
  }
};

module.exports = {
  artifactsStep,
  checkoutStep,
  ciShSteps,
  ciShStepsDeploy,
  env,
  matrixContainer,
  matrixOs,
  stage1Jobs,
  stage2Jobs
};
