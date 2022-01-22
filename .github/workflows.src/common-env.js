/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

// -----------------------------------------------------------------------------

let env = {
  GITHUB_TOKEN: '${{ secrets.GITHUB_TOKEN }}',
  YP_LOG_BOOTSTRAP: true,
  YP_PRINTENV_BOOTSTRAP: '${{ secrets.YP_PRINTENV_BOOTSTRAP }}',
  YP_TRANSCRYPT_PASSWORD: '${{ secrets.YP_TRANSCRYPT_PASSWORD }}',
  V: '${{ secrets.V }}'
};

module.exports = {
  env
};
