# support-firecloud

* Travis CI: [![Travis CI Status][2]][1]
* CircleCI [![CircleCI Status][4]][3]
* Github Actions CI [![Github Actions CI Status][6]][5]

Software and configuration that support TobiiPro's Cloud Services development.


**IMPORTANT:** Almost all github.com/tobiipro repositories have `support-firecloud` as a git submodule.
It is therefore **important that you clone these repositories recursively**, otherwise `make` **will** fail.
* use `git clone --recursive ...`
* or run `git submodule update --init --recursive` after cloning.


## Documentation

* newcomer
  * [bootstrap](doc/bootstrap.md)
  * [bootstrap your editor](doc/bootstrap-your-editor.md)
  * [bootstrap AWS (console and CLI)](doc/bootstrap-aws.md) (optional)
  * [bootstrap your `gpg` signature](doc/bootstrap-gpg.md) (optional)
* daily work
  * [`git` (and Github) Pull Requests](doc/working-with-git-pr.md)
  * [working with `make`](doc/working-with-make.md)
  * [working with a local `npm` dependency](doc/working-with-a-local-npm-dep.md)
  * [how to release](doc/how-to-release.md)
  * style
    * `Use common sense and BE CONSISTENT. (Google)`
    * [shell](doc/style-sh.md)
    * [Makefile](doc/style-mk.md)
    * [JavaScript/TypeScript](https://github.com/rokmoln/eslint-config-firecloud)
    * [SASS](https://github.com/rokmoln/sass-lint-config-firecloud)
* set up a new `git` repository
  * [new `git` (and Github) repositories](doc/working-with-git-new.md)
  * [how to license](doc/how-to-license.md)
  * [integrate Travis CI](doc/integrate-travis-ci.md)
  * [.ci.sh](doc/ci-sh.md)
  * [how to manage secrets](doc/how-to-manage-secrets.md)
* Amazon Web Services
  * [CloudFormation](repo/cfn/README.md)
  * [Identity Access Management](doc/aws-iam.md)

* Internals
  * [Offboarding](doc/offboarding.secret.md)


## Structure

* `/bin` has executable shell scripts
* `/sh` has common include shell scripts e.g. sourced from `/bin` shell scripts
*
* `/ci` has scripts that help bootstrap a CI machine
* `/dev` has scripts that help bootstrap a developer machine
* `/dockerfiles` has Dockerfiles bootstrapped with `support-firecloud`
*
* `/generic` has configuration that is not repo-specific
* `/repo` has configuration that is repo-specific, for those repositories bootstrapped with `support-firecloud`


## Writing

https://developers.google.com/tech-writing/overview


## License

[Apache-2.0](LICENSE)


  [1]: https://travis-ci.com/rokmoln/support-firecloud
  [2]: https://travis-ci.com/rokmoln/support-firecloud.svg?branch=master
  [3]: https://circleci.com/gh/tobiipro/support-firecloud/tree/master
  [4]: https://circleci.com/gh/tobiipro/support-firecloud/tree/master.svg?style=svg
  [5]: https://github.com/rokmoln/support-firecloud/actions?query=workflow%3ACI+branch%3Amaster
  [6]: https://github.com/rokmoln/support-firecloud/workflows/CI/badge.svg?branch=master
