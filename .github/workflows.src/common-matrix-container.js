/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let matrixContainer = {
  arch: [
    'arch-0'
  ],
  alpine: [
    'alpine-3.15'
  ],
  amzn: [
    'amzn-2'
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

let matrixContainerWithSmoke = _.clone(matrixContainer);
matrixContainerWithSmoke.smoke = [
  'ubuntu-20.04'
];
_.forEach(matrixContainerWithSmoke, function(_os, group) {
  if (group === 'smoke') {
    return;
  }
  matrixContainerWithSmoke[group] = _.without(matrixContainerWithSmoke[group], ...matrixContainerWithSmoke.smoke);
});

module.exports = {
  matrixContainer,
  matrixContainerWithSmoke
};
