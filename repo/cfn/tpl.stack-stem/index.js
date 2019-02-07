#!/usr/bin/env node

require('aws-util-firecloud/lib/bootstrap');

let _ = require('lodash-firecloud');
let build = require('aws-util-firecloud/lib/cfn/build');
let env = require('aws-util-firecloud/lib/env');

let main = async function({env}) {
  let tpl = await build({
    env,
    dir: env.STACK_STEM
  });
  return tpl;
};

export default main;

(async function() {
  if (!module.parent) {
    // eslint-disable-next-line no-console
    console.log(JSON.stringify(await main({env}), undefined, 2));
  }
})();
