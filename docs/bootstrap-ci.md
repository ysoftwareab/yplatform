# CI

## settings

Run `ci/osx/bootstrap` to install OSX system dependencies.

Run `ci/linux/bootstrap` to install Ubuntu system dependencies (sudo required).

Run `ci/linux-nosudo/bootstrap` to install Ubuntu system dependencies (sudo not required, minimal setup).
This bootstrapping procedure is useful for small repos with minimal system dependencies, making the CI run faster
e.g. Travis CI has a `sudo: false` setting that switches from a VM-based system to a container-based one
(see https://docs.travis-ci.com/user/reference/overview/#Virtualization-environments).
