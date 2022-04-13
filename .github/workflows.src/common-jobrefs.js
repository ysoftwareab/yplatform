/* eslint-disable no-template-curly-in-string */

let _ = require('lodash-y');

let {matrixContainer} = require('./common-matrix-container');
let {matrixOs} = require('./common-matrix-os');

let jobRefs = {};

jobRefs.main = _.reduce(_.keys(matrixOs), function(jobRefs, nameSuffix) {
  jobRefs.push(`main-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.maincMinimal = _.reduce(_.keys(matrixContainer), function(jobRefs, nameSuffix) {
  jobRefs.push(`mainc-minimal-${nameSuffix}`);
  return jobRefs;
}, []);

jobRefs.maincCommon = _.reduce(_.keys(matrixContainer), function(jobRefs, nameSuffix) {
  jobRefs.push(`mainc-common-${nameSuffix}`);
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

module.exports = {
  jobRefs
};
