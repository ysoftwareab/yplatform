/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let matrixContainer = {
  arch: [
    'yp-arch-0'
  ],
  alpine: [
    'yp-alpine-3.11.7'
  ],
  centos: [
    'yp-centos-8'
  ],
  debian: [
    'yp-debian-9',
    'yp-debian-10'
  ],
  ubuntu: [
    'yp-ubuntu-16.04',
    'yp-ubuntu-18.04',
    'yp-ubuntu-20.04'
  ]
};

module.exports = {
  matrixContainer
};
