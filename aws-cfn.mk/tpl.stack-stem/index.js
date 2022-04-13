#!/usr/bin/env node

// eslint-disable-next-line import/no-unassigned-import
require('aws-util-y/lib/bootstrap');

let _ = require('lodash-y');
let build = require('aws-util-y/lib/cfn/build');

let main = async function({env}) {
  let tpl = await build({
    env,
    dir: env.STACK_STEM
  });
  return tpl;
};

module.exports = main;

(async function() {
  if (!module.parent) {
    let env = _.safeProxy(process.env);

    // eslint-disable-next-line no-console, no-null/no-null
    console.log(JSON.stringify(await main({env}), null, 2));
  }
})();
