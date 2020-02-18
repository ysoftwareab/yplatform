# `.ci.sh`

The CI/CD mindset of `support-firecloud` is to be 99% agnostic to the CI/CD platform it runs on.

Therefore we don't run (write) actual code in the CI platform configurations e.g. `.travis.yml`.
Instead we call a `.ci.sh` script and leave it to that.
All CI/CD instrumentation is to be written in proper shell scripts,
and we sensible steer away from non-essential built-in features like installing specific language versions,
or installing system packages in the CI platform configurations.

Due to historical reasons, Travis CI being the first CI/CD platform we integrated with,
but also because their pipeline makes sense, we follow their job lifecycle and their "phase" names,
currently described at https://docs.travis-ci.com/user/job-lifecycle/ .

* `before_install`
  * see [repo/ci.sh/before-install.pre.inc.sh](../repo/ci.sh/before-install.pre.inc.sh)
  * see [repo/ci.sh/before-install.inc.sh](../repo/ci.sh/before-install.inc.sh)
  * maybe run the Docker container for Travis CI. See [integrate-travis-ci.md#docker](integrate-travis-ci.md#docker)
  * check out code (including git submodules)
  * bootstrap the CI agent with system dependencies as instructed via `Brewfile.inc.sh`
* `install`
  * see [repo/ci.sh/install.inc.sh](../repo/ci.sh/install.inc.sh)
  * equivalent to running `make deps`
*
* `before_script`
* `script`
  * see [repo/ci.sh/script.inc.sh](../repo/ci.sh/script.inc.sh)
  * equivalent to running `make build check test`
* `before_cache`
  * see [repo/ci.sh/before-cache.inc.sh](../repo/ci.sh/before-cache.inc.sh)
* `after_success`
  * exit code doesn't affect build's success/failure
  * called only if the `script` phase succeeds
* `after_failure`
  * exit code doesn't affect build's success/failure
  * called only if the `script` phase fails
*
* `before_deploy`
  * see [repo/ci.sh/before-deploy.inc.sh](../repo/ci.sh/before-deploy.inc.sh)
  * equivalent to running `make snapshot && make dist`
* `deploy`
* `after_deploy`
  * exit code doesn't affect build's success/failure
*
* `after_script`
  * see [repo/ci.sh/after-script.inc.sh](../repo/ci.sh/after-script.inc.sh)
  * maybe upload job artifacts. See [integrate-travis-ci.md#artifacts](integrate-travis-ci.md#artifacts)
  * exit code doesn't affect build's success/failure
  * called after `after_success` or `after_failure`, optionally `after_deploy`

A couple of special "phases", not defined by Travis CI, exist as well:
* `debug`
  * see [repo/ci.sh/debug.inc.sh](../repo/ci.sh/debug.inc.sh)
  * Travis CI has functionality to start an agent and then ssh into it
  * once you do, run `./.ci.sh debug`. See [integrate-travis-ci.md#debugging](integrate-travis-ci.md#debugging)
* `notifications`
  * see [repo/ci.sh/notifications.inc.sh](../repo/ci.sh/notifications.inc.sh)
  * Travis CI has built-in functionality for job notifications on success/failure.
    But other platforms, like Github Actions, do not have such functionality,
    therefore one needs an extra final phase to send out notifications.
  * exit code doesn't affect build's success/failure

For each phase in `.travis.yml`, we simply call `./.ci.sh <phase>`.
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
where we actually call `sf_ci_run <phase>`.

The `sf_ci_run` function will mainly check

* if there's a `ci_run_<phase>` function defined, call it
* otherwise, if there's a `sf_ci_run_<phase>`, call that one instead.

`ci_run_<phase>` functions are custom implementations for each phase,
while `sf_ci_run_<phase>` are default implementations,
mainly wrapping the `make` targets defined in [repo/mk](../repo/mk).


## Patterns

Since several repositories might follow similar patterns in their CI/CD executions,
we have grouped these custom `ci_run_<phase>` functions in

* [sh/app-env.inc.sh](../sh/app-env.inc.sh) is a pattern for web apps, with external deployments
* [sh/app.inc.sh](../sh/app.inc.sh) is a pattern for desktop/mobile apps, with github releases
  * FIXME I believe this one was overengineered. Do we need to upload artifacts (installers) to AWS, etc?

These patterns can be reused by simply changing the `.ci.sh` template above to include at the bottom:

```
source "${SUPPORT_FIRECLOUD_DIR}/sh/app-env.inc.sh"
source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
```
