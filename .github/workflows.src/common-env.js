/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

// -----------------------------------------------------------------------------

let env = {
  GITHUB_TOKEN: '${{ secrets.GITHUB_TOKEN }}',
  YP_CI_ECHO_EXTERNAL_HONEYCOMB_API_KEY: '${{ secrets.YP_CI_ECHO_EXTERNAL_HONEYCOMB_API_KEY }}',
  YP_CI_ECHO_EXTERNAL_HONEYCOMB_DATASET: '${{ secrets.YP_CI_ECHO_EXTERNAL_HONEYCOMB_DATASET }}',
  YP_LOG_BOOTSTRAP: true,
  YP_PRINTENV_BOOTSTRAP: '${{ secrets.YP_PRINTENV_BOOTSTRAP }}',
  YP_TRANSCRYPT_PASSWORD: '${{ secrets.YP_TRANSCRYPT_PASSWORD }}',
  V: '${{ secrets.V }}'
};

module.exports = {
  env
};
