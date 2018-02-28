# Repository

## settings

Set up `support-firecloud` as a git submodule via

```shell
git submodule add support-firecloud git://github.com/tobiipro/support-firecloud.git
ln -s {support-firecloud/repo/dot,}.editorconfig
ln -s {support-firecloud/repo/dot,}.npmrc
ln -s {support-firecloud/repo/dot,}.vscode

```
## Travis

`cp {support-firecloud/ci/dot,}travis.sh` in your repo, and modify accordingly like:

* replace/remove `secure`values
* replace/remove `matrix` configuration
* etc

Create `.travis.sh` by

* symlinking `ln -s {support-firecloud/ci/dot,}travis.sh`
* or copying (allows for modifications) `cp {support-firecloud/,./}.travis.sh`
