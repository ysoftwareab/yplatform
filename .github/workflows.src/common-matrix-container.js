/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let matrixContainer = {
  arch: [
    'arch-0'
  ],
  alpine: [
    'alpine-3.11.7'
  ],
  centos: [
    'centos-8'
  ],
  debian: [
    'debian-9',
    'debian-10'
  ],
  ubuntu: [
    'ubuntu-16.04',
    'ubuntu-18.04',
    'ubuntu-20.04'
  ]
};

module.exports = {
  matrixContainer
};
