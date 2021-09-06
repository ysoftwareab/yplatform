# `.ci.sh`

The CI/CD mindset of `support-firecloud` is to be 99% agnostic to the CI/CD platform it runs on.

Therefore we don't run (write) actual code in the CI platform configurations.
Instead we call a `.ci.sh` script and leave it to that.
All CI/CD instrumentation is to be written in proper shell scripts,
and we sensible steer away from non-essential built-in features like installing specific language versions,
or installing system packages in the CI platform configurations.

## Code execution

A normal `.ci.sh` file would follow the template in [repo/dot.ci.sh](../repo/dot.ci.sh) e.g.

```shell
#!/usr/bin/env bash

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

## to override an existing phase implementation
# function ci_run_<phase>() {
# }

## to wrap an existing phase implementation
# eval "original_$(declare -f ci_run_<phase>)"
# function ci_run_<phase>() {
#   ...
#   original_ci_run_<phase>
#   ...
# }
#

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
```

Code execution really starts at the bottom of [repo/dot.ci.sh.sf](../repo/dot.ci.sh.sf),
where we actually call `sf_ci_run <phase>`.

The `sf_ci_run` function will mainly check

* if there's a `ci_run_<phase>` function defined, call it
* otherwise, if there's a `sf_ci_run_<phase>`, call that one instead.

`ci_run_<phase>` functions are custom implementations for each phase,
while `sf_ci_run_<phase>` are default implementations,
mainly wrapping the `make` targets defined in [build.mk](../build.mk).


## Customization via git commit message

If a git commit message contains `[skip ci]` and the CI doesn't automatically skip this commit,
we will automatically `exit 0`.

If a git commit message contains `[debug ci]`, we will start a [`tmate`](https://tmate.io) session
and print the SSH/WEB links.

If a git commit message contains `[env FOO=bar]`, we will set the environment variable `FOO` to `bar`.


## Customization via environment variables

Customizations can take place in two ways:
either write a `ci_run_<phase>` function in `.ci.sh` as mentioned above, or set environment variables.

Here's a list of the environment variables that customize the code execution:

* **BOOTSTRAP**
  * `SF_CI_ECHO_BENCHMARK`
    * set to a file that will collect `bin/ci-echo` DO-DONE durations for benchmarking
  * `SF_LOG_BOOTSTRAP`
    * set to `true` to enable printing the whole bootstrap log which is hidden by default
  * `SF_PRINTENV_BOOTSTRAP`
    * set to `true` to enables printing all environment variables
  * `SF_SKIP_BREW_BOOTSTRAP`
    * set to `true` to skip brew bootstrapping `bootstrap/brew-bootstrap.inc.sh`
  * `SF_SKIP_SUDO_BOOTSTRAP`
    * set to `true` to skip sudo bootstrapping `bootstrap/<OS_SHORT>/bootstrap-sudo`
  * `SF_SUDO`
    * set to `sf_nosudo` to bootstrap without sudo
    * set to a custom `sudo` executable path

* **GITHUB**
  * `SF_GH_TOKEN`
    * enables authenticated HTTPS for git calls to github.com instead of SSH
    * defaults to another environment variable `GH_TOKEN`
  * `SF_GH_TOKEN_DEPLOY`
    * a deploy token that enables read/push to the current repo
    * defaults to another environment variable `GITHUB_TOKEN` in Github Actions (automatic deploy key)
      * see [Authentication in a workflow](https://docs.github.com/en/actions/reference/authentication-in-a-workflow#permissions-for-the-github_token)

* **TRANSCRYPT**
  * `SF_TRANSCRYPT_PASSWORD`
    * enables automatic setup of `transcrypt`.
    * see [how-to-manage-secrets.md](how-to-manage-secrets.md)
    * defaults to another environment variable `TRANSCRYPT_PASSWORD` for backwards compatibility
  * `SF_TRANSCRYPT_CIPHER`
    * customizes the `transcrypt` cipher, defaults to `aes-256-cbc`
    * defaults to another environment variable `TRANSCRYPT_CIPHER` for backwards compatibility

* **DOCKER ON TRAVIS CI**
  * `SF_DOCKER_CI_IMAGE`
    * customizes the Docker image for `docker pull`
    * set to `false` to disable running inside a Docker image altogether
  * `SF_DOCKER_CI_USERNAME`/`SF_DOCKER_CI_TOKEN`
    * enable pulling the Docker image with credentials
    * defaults to another environment variable `DOCKER_USERNAME`/`DOCKER_TOKEN`
  * `SF_DOCKER_CI_SERVER`
    * customizes the identity server for `docker login`

* **DEBUG**
  * `SF_TMATE_AUTH`
    * a path to a `~/.ssh/authorized_keys` file (i.e. one public key per line)
    * restricts who can access the tmate session triggered by a `[debug ci]` commit
    * set to `none` if you don't want to restrict and have an insecure session


## Phases

Due to historical reasons, Travis CI being the first CI/CD platform we integrated with,
but also because their pipeline makes sense, we follow their job lifecycle and their "phase" names,
currently described at https://docs.travis-ci.com/user/job-lifecycle/ .

* `before_install`
  * see [ci/before-install.pre.inc.sh](../ci/before-install.pre.inc.sh)
  * see [ci/before-install.inc.sh](../ci/before-install.inc.sh)
  * maybe run the Docker container for Travis CI. See [integrate-travis-ci.md#docker](integrate-travis-ci.md#docker)
  * check out code (including git submodules)
  * bootstrap the CI agent with system dependencies as instructed via `Brewfile.lock` and `Brewfile.inc.sh`
    * `Brewfile.lock` has `<brew-or-tap> <commitish> <date of commit-ish to fetch>` lines
    * `Brewfile.inc.sh` can call any commands, but `brew_install` is preferred, to install system dependencies
* `install`
  * see [ci/install.inc.sh](../ci/install.inc.sh)
  * equivalent to running `make deps`
*
* `before_script`
* `script`
  * see [ci/script.inc.sh](../ci/script.inc.sh)
  * equivalent to running `make build check test`
* `before_cache`
  * see [ci/before-cache.inc.sh](../ci/before-cache.inc.sh)
* `after_success`
  * exit code doesn't affect build's success/failure
  * called only if the `script` phase succeeds
* `after_failure`
  * exit code doesn't affect build's success/failure
  * called only if the `script` phase fails
*
* `before_deploy`
  * see [ci/before-deploy.inc.sh](../ci/before-deploy.inc.sh)
  * equivalent to running `make snapshot && make dist`
* `deploy`
* `after_deploy`
  * exit code doesn't affect build's success/failure
*
* `after_script`
  * see [ci/after-script.inc.sh](../ci/after-script.inc.sh)
  * maybe upload job artifacts. See [integrate-travis-ci.md#artifacts](integrate-travis-ci.md#artifacts)
  * exit code doesn't affect build's success/failure
  * called after `after_success` or `after_failure`, optionally `after_deploy`

A couple of special "phases", not defined by Travis CI, exist as well:
* `debug`
  * see [ci/debug.inc.sh](../ci/debug.inc.sh)
  * Travis CI has functionality to start an agent and then ssh into it
  * once you do, run `./.ci.sh debug`. See [integrate-travis-ci.md#debugging](integrate-travis-ci.md#debugging)
* `notifications`
  * see [ci/notifications.inc.sh](../ci/notifications.inc.sh)
  * Travis CI has built-in functionality for job notifications on success/failure.
    But other platforms, like Github Actions, do not have such functionality,
    therefore one needs an extra final phase to send out notifications.
  * exit code doesn't affect build's success/failure

For each phase in the CI pipeline, we simply call `./.ci.sh <phase>`.
Similarly, we can reproduce this pipeline in CircleCI, Github Actions, etc.

See for yourself. Search `.ci.sh before_install` in

* [.appveyor.yml](../.appveyor.yml)
* [.circleci/config.yml](../.circleci/config.yml)
* [.cirrus.yml](../.cirrus.yml)
* [.codeship-steps.yml](../.codeship-steps.yml)
* [.github/workflows/main.yml](../.github/workflows/main.yml)
* [.gitlab-ci.yml](../.gitlab-ci.yml)
* [.travis.yml](../.travis.yml)


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


## Environment variables

* CI
* SF_CI_NAME
* SF_CI_PLATFORM
* SF_CI_SERVER_HOST
* SF_CI_REPO_SLUG
* SF_CI_ROOT
* ---
* SF_CI_IS_CRON
* SF_CI_IS_PR
* ---
* SF_CI_JOB_ID
* SF_CI_PIPELINE_ID
* SF_CI_JOB_URL
* SF_CI_PIPELINE_URL
* ---
* SF_CI_PR_NUMBER
* SF_CI_PR_URL
* SF_CI_PR_REPO_SLUG
* SF_CI_PR_GIT_HASH
* SF_CI_PR_GIT_BRANCH
* ---
* SF_CI_GIT_HASH
* SF_CI_GIT_BRANCH
* SF_CI_GIT_TAG
* ---
* SF_CI_DEBUG_MODE
* SF_CI_PHASES
* SF_CI_STEP_NAME
* SF_CI_ECHO
* SF_CI_STATUS
