/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-firecloud');

let matrixOs = {
  smoke: [
    'ubuntu-20.04'
  ],
  ubuntu: [
    // deprecated in https://github.com/actions/virtual-environments/issues/3287
    // "ubuntu-16.04",
    'ubuntu-18.04'
    // part of 'smoke'
    // 'ubuntu-20.04'
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
  smoke: [
    'sf-ubuntu-20.04'
  ],
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
    'sf-ubuntu-18.04'
    // part of 'smoke'
    // 'sf-ubuntu-20.04'
  ]
};

let jobRefs = {};

jobRefs.main = _.reduce(_.keys(matrixOs), function(jobRefs, nameSuffix) {
  jobRefs.push(`main-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.mainc = _.reduce(_.keys(matrixContainer), function(jobRefs, nameSuffix) {
  jobRefs.push(`mainc-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.deploycMinimal = _.reduce(_.keys(matrixContainer), function(jobRefs, nameSuffix) {
  jobRefs.push(`deployc-minimal-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.deploycCommon = _.reduce(_.keys(matrixContainer), function(jobRefs, nameSuffix) {
  jobRefs.push(`deployc-common-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.smokeMain = [
  'main-smoke',
  'mainc-smoke'
];

jobRefs.smokeMainc = _.concat(jobRefs.smokeMain, jobRefs.main);
// ignore windows, because it is very very very slow
jobRefs.smokeMainc = _.without(jobRefs.smokeMainc, 'main-windows');

jobRefs.smokeDeploycMinimal = [
  'deployc-common-smoke'
];

module.exports = {
  jobRefs,
  matrixContainer,
  matrixOs
};
