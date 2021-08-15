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

let jobRefs = {};

jobRefs.main = _.reduce(_.keys(matrixOs), function(needs, nameSuffix) {
  needs.push(`main-${nameSuffix}`);
  return needs;
}, []);

jobRefs.mainc = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`mainc-${nameSuffix}`);
  return needs;
}, []);

jobRefs.deploycMinimal = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`deployc-minimal-${nameSuffix}`);
  return needs;
}, []);

jobRefs.deploycCommon = _.reduce(_.keys(matrixContainer), function(needs, nameSuffix) {
  needs.push(`deployc-common-${nameSuffix}`);
  return needs;
}, []);


let stage1Jobs = [
  'main-ubuntu'
];

let stage2Jobs = jobRefs.main;

let stage3Jobs = jobRefs.mainc;

let stage4Jobs = jobRefs.deploycMinimal;

let stage5Jobs = jobRefs.deploycCommon;

module.exports = {
  jobRefs,
  matrixContainer,
  matrixOs,
  stage1Jobs,
  stage2Jobs,
  stage3Jobs,
  stage4Jobs,
  stage5Jobs
};
