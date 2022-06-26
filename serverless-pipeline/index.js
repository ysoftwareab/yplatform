#!/usr/bin/env node

Error.stackTraceLimit = Infinity;

let _ = require('lodash-firecloud');
let fs = require('fs');
let partialInfra = require('./index.1.infra');
let partialImportConsumer = require('./index.2.import-consumer');

let description = fs.readFileSync(`${__dirname}/README.md`, 'utf8')

let main = async function({env = {}} = {}) {
  let tpl = {
    AWSTemplateFormatVersion: '2010-09-09',
    Metadata: {
      License: 'Unlicense'
    },
    Description: description,
    Parameters: {},
    Resources: {},
    Outputs: {}
  };

  _.merge(tpl, await partialInfra({env}));
  _.merge(tpl, await partialImportConsumer({env}));

  return tpl;
};

module.exports = main;

(async function() {
  if (!module.parent) {
    console.log(JSON.stringify(await main(), null, 2));
  }
})();
