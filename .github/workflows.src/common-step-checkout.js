/* eslint-disable no-template-curly-in-string */

let fs = require('fs');
let _ = require('lodash-y');

let githubCheckout = fs.readFileSync(`${__dirname}/../../bin/github-checkout`, 'utf8');

let checkoutStep = {
  name: 'yplatform/bin/github-checkout',
  shell: 'bash',
  run: [
    'set -x',
    githubCheckout
  ].join('\n')
};

module.exports = {
  checkoutStep
};
