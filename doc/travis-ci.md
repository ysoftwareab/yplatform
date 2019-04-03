# Travis CI

Hopefully you have some tests or just lint checks that you want to run
in a continuous manner, whenever new commits are pushed or on code from pull requests.

We currently use Travis CI and thus prefer it for consistency, but other CIs are ok given reasonable consideration.

A very first step to setup an integration with Travis CI is to visit https://github.com/organizations/tobiipro/settings/installations,
press `Configure` next to `Travis CI` and make sure that Travis
has access to your repo in the `Repository access` section dropdown.

Then go to https://travis-ci.com/profile/tobiipro
and find your repo in the list to open its settings.

## Repository's Travis CI settings

It is recommended that on the repository's Travis CI settings page you
* **if you have long-running builds such as deployment to AWS CloudFormation**,
  enable `Limit concurrent jobs: 1`
* enable `Auto cancel branch builds`
* enable `Auto cancel pull request builds`
* add cronjob `master - daily - Always run`
* (preferred, but not obligatory) replace default SSH key with `tobiiprotools` 
SSH key (can be found in **designated safe location**).

## In the repo

### `README.md` and status image

Link to the repository's page on Travis CI
and embed a status image for the `master` branch (or more) in `README.md`, in short add:

```md
# <software product> [![Build Status][2]][1]

...

  [1]: https://travis-ci.com/tobiipro/<repo>
  [2]: https://travis-ci.com/tobiipro/<repo>.svg?branch=master
```

**NOTE** for private repositories, you'll want to go https://travis-ci.com/tobiipro/<repo>,
click the status image, select 'Image URL' and copy the SVG URL (the link has a unique token).

Reference: https://docs.travis-ci.com/user/status-images/

### `.travis.yml`

Don't forget to commit the most important thing: a `.travis.yml` ([template](../repo/dot.travis.yml)) file which configures your Travis CI build.


## Artifacts

If your job has artifacts, like logs that you'd like to access outside of the Travis CI job log,
then you need to

* Add a `GH_TOKEN` secure environment variable to `.travis.yml`.
  This Github API token should have enough permissions to push to the repository.
* Create a `.artifacts`

The `.artifacts` file is a list of paths that would include artifacts e.g.

```
some.log
some/folder/*.log
```

Once you do, your artifacts would be uploaded to a `refs/jobs/<job_id>` git ref,
making it possible to browse the artifacts via Github's UI,
or checking them out via `git fetch refs/jobs/<job_id> && git log -p FETCH_HEAD`
(or even `git checkout FETCH_HEAD`) from a local repo.


## Debugging

If you experience failures and you want to debug inside a Travis worker,
you can press the `Debug build` button in the top-right corner, and, after some minutes,
you should get an `ssh` command to execute in the output log, like

```
ssh rFjXYvZt3FotUuXVOKo1z2WOc@to2.tmate.io
```

For official info, see [how to debug](https://docs.travis-ci.com/user/running-build-in-debug-mode/).

If you debug often, you can speed up the process,
by running `support-firecloud/bin/travis-debug --token X --job Y`, where
- X is the token that you see at https://travis-ci.com/profile/
  - you can omit `--token X` if you have an environment variable `TRAVIS_API_TOKEN`
- Y can be a numeric job ID or a job URL or even a build URL (most useful)

**NOTE** Remember that you can almost always run `--help`,
so `support-firecloud/bin/travis-debug --help`, to get proper info.

Once you SSH via the tmate session, you will be welcomed by the message:

>   Run individual commands; or execute configured build phases
>   with `travis_run_*` functions (e.g., `travis_run_before_install`).

So run `travis_run_before_install` in order to bootstrap the machine.
Once that command finishes, you will be welcome by the message:

>   Please run `./.travis.sh debug` to activate your debug session !!!

So run `./.travis.sh debug` in order to setup the shell session (e.g. environment variables like `PATH`).

**NOTE** If `travis_run_before_install` fails and crashes the tmate session, you can try running `./.travis.sh before-install` (equivalent but safer).


## Secrets

**NOTE** See related docs on [how to manage secrets](how-to-manage-secrets.md).

### Web UI Secrets (preferred)

If you have Travis-specific values to encrypt,
then you can add encrypted values via the web UI of Travis CI:
`project -> More Options -> Settings -> Environment Variables`.

By default, all environment variables added like this are encrypted (secret; not displayed in the logs).

### `.travis.yml` secrets

Two exceptions from adding secret variables through web UI 
and using instead `.travis.yml` file (that only Travis CI can decrypt):
* configuration for Slack notifications
* Githib Releases provider API key

You'll need to use the official (and Ruby heavy) [Travis CI client](https://github.com/travis-ci/travis.rb) for that.
On OSX run `brew install travis` to install it.

```shell
travis encrypt --com something_super_secret
```

Now you can add the `secret: "..."` text to your `.travis.yml` file.

For more info, see:
* https://docs.travis-ci.com/user/encryption-keys/
* https://docs.travis-ci.com/user/best-practices-security/

### `transcrypt`-ed repository

If your repository is `transcrypt`-ed, and you want to access the secrets in Travis CI, 
you need to add `TRANSCRYPT_PASSWORD` variable in Travis Web UI.

The decryption of the repository will happen automatically in non-pull-request builds,
if `.travis.yml` runs `./travis.sh before_install` in `before_install`
(default in the [`.travis.yml` template](../repo/dot.travis.yml); see [actual command](../repo/dot.travis.sh)).


### Migrating secrets from existing repo

To make the setup faster and avoid looking for secrets all over different places, 
you can _manually_ get all the secrets in existing repo. 

To do so,
start a debugging session as described in [debugging section](#Debugging).

After logging in, run command(s) to get your var values.

```shell
printenv | grep MY_SECRET_VAR_PREFIX_
```

## Notifications

### Slack

* Go to https://tobii.slack.com/apps/, find "Travis CI" and there existing integration between Travis and Tobii Slack
* Click "pencil" button ("Edit configuration") and note `<token>`
* Open terminal in the repo folder
* Generate new Travis secret as mentioned in [Secrets](#Secrets).
Assuming that you want notifications in #atex-ci channel command will look like:
  * in a case of public repo `support-firecloud/bin/travis-encrypt "tobii:<token>#atex-ci"`
  * in a case of private repo `travis encrypt "tobii:<token>#atex-ci"` (you will need to run `travis login --pro` before that)
* Add secret in the `.travis.yml` and configure other options
```yaml
notifications:
  email: true
  slack:
    rooms:
      # atex-ci
      - secure: "<your encrypted token here>"
    on_success: change
    on_pull_requests: false
```


## Releases

If you are planning to release via Travis CI (primarily for high-level packages), see 
[how to release](how-to-release.md#npm-packages-as-github-artifacts).
