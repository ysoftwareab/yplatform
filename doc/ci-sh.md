# `.ci.sh`

The CI/CD mindset of `support-firecloud` is to be 99% agnostic to the CI/CD platform it runs on.

Therefore we don't run (write) actual code in the CI platform configurations e.g. `.travis.yml`.
Instead we call a `.ci.sh` script and leave it to that.
All CI/CD instrumentation is to be written in proper shell scripts,
and we sensible steer away from non-essential built-in features like installing specific language versions,
or installing system packages in the CI platform configurations.

Due to historical reasons, Travis CI being the first CI/CD platform we integrated with,
but also because their pipeline makes sense, we follow their job lifecycle and their "stage" names,
currently described at https://docs.travis-ci.com/user/job-lifecycle/ .

* `before_install`
  * maybe run the Docker container for Travis CI. See [integrate-travis-ci.md#docker](integrate-travis-ci.md#docker)
  * check out code (including git submodules)
  * bootstrap the CI agent with system dependencies as instructed via `Brewfile.inc.sh`
* `install`
  * equivalent to running `make deps`
*
* `before_script`
* `script`
  * equivalent to running `make build check test`
* `before_cache`
* `after_success`
  * exit code doesn't affect build's success/failure
  * called only if the `script` stage succeeds
* `after_failure`
  * exit code doesn't affect build's success/failure
  * called only if the `script` stage fails
*
* `before_deploy`
  * equivalent to running `make snapshot && make dist`
* `deploy`
* `after_deploy`
  * exit code doesn't affect build's success/failure
*
* `after_script`
  * maybe upload job artifacts. See [integrate-travis-ci.md#artifacts](integrate-travis-ci.md#artifacts)
  * exit code doesn't affect build's success/failure
  * called after `after_success` or `after_failure`, optionally `after_deploy`

A couple of special "stages", not defined by Travis CI, exist as well:
* `debug`
  * Travis CI has functionality to start an agent and then ssh into it
  * once you do, run `./.ci.sh debug`. See [integrate-travis-ci.md#debugging](integrate-travis-ci.md#debugging)
* `notifications`
  * Travis CI has built-in functionality for job notifications on success/failure.
    But other platforms, like Github Actions, do not have such functionality,
    therefore one needs an extra final stage to send out notifications.
  * exit code doesn't affect build's success/failure

For each stage in `.travis.yml`, we simply call `./.ci.sh <stage>`.
Similarly, we can reproduce this pipeline in CircleCI, Github Actions, etc.

See for yourself. Search `.ci.sh before_install` in

* [.travis.yml](../.travis.yml)
* [.circleci/config.yml](../.circleci/config.yml)
* [.github/workflows/main.yml](../.github/workflows/main.yml)


## Code execution

A normal `.ci.sh` file would follow the template in [repo/dot.ci.sh](../repo/dot.ci.sh) e.g.

```shell
#!/usr/bin/env bash

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

# function ci_run_<step>() {
# }

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
```

Code execution really starts at the bottom of [repo/dot.ci.sh.sf](../repo/dot.ci.sh.sf),
where we actually call `sf_ci_run <stage>`.

The `sf_ci_run` function will mainly check

* if there's a `ci_run_<stage>` function defined, call it
* otherwise, if there's a `sf_ci_run_<stage>`, call that one instead.

`ci_run_<stage>` functions are custom implementations for each stage,
while `sf_ci_run_<stage>` are default implementations,
mainly wrapping the `make` targets defined in [repo/mk](../repo/mk).


## Patterns

Since several repositories might follow similar patterns in their CI/CD executions,
we have grouped these custom `ci_run_<stage>` functions in

* [sh/app-env.inc.sh](../sh/app-env.inc.sh) is a pattern for web apps, with external deployments
* [sh/app.inc.sh](../sh/app.inc.sh) is a pattern for desktop/mobile apps, with github releases
  * FIXME I believe this one was overengineered. Do we need to upload artifacts (installers) to AWS, etc?

These patterns can be reused by simply changing the `.ci.sh` template above to include at the bottom:

```
source "${SUPPORT_FIRECLOUD_DIR}/sh/app-env.inc.sh"
source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
```
