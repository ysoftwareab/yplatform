#!/usr/bin/env node -r babel-register

import 'aws-util-firecloud/lib/bootstrap';

import _ from 'lodash-firecloud';
import build from 'aws-util-firecloud/lib/cfn/build';
import env from 'aws-util-firecloud/lib/env';

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
    console.log(JSON.stringify(await main({env}), undefined, 2));
  }
})();
