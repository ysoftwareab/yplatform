/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

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
  needs.push(`main-${nameSuffix}`);
  return needs;
}, []);

let stage3Jobs = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`mainc-${nameSuffix}`);
  return needs;
}, []);

let stage4Jobs = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`deployc-minimal-${nameSuffix}`);
  return needs;
}, []);

let stage5Jobs = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`deployc-common-${nameSuffix}`);
  return needs;
}, []);

module.exports = {
  matrixContainer,
  matrixOs,
  stage1Jobs,
  stage2Jobs,
  stage3Jobs,
  stage4Jobs,
  stage5Jobs
};
