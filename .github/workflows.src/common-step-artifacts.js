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
  artifactsStep
};
