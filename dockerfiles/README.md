# Docker images

Docker images are built on each release of `yplatform`,
and pushed to https://hub.docker.com/u/ysoftwareab .

These images can then be used in CIs to skip not only the time-consuming process of bootstrapping,
but also to increase the determinism of the execution,
since there's absolute control on when and how the execution environment changes.

The images have

* an `yp:yp` sudoer user, intended as default user (don't use `root`)
* a `/yplatform` git clone
* a `/yplatform.bootstrapped` marker to denote that this machine has been bootstrapped
  * the file contents are the git hash of the `/yplatform` HEAD
* no aptitude cache (to reduce size)
* shallow git clones (to reduce size)
* linuxbrew installed, along with a collection of minimal/common packages


## `dockerfiles/yp-<id>-<version-id>/run`

A `run` utility will make it easy to run ephemeral (`--rm`) instances of these images.
It takes a FLAVOUR argument as following:

* `./run vanilla` will run the vanilla image that our image is based on e.g. `ubuntu-20.04:latest`
* `./run yp-minimal` or `./run yp-common` will run the image associated with the current `yplatform` version
* `./run yp-minimal:<tag>` or `./run yp-common:<tag>` will run the image with the given tag

**NOTE** No `--help` argument exists yet. Check the sourcecode for available arguments.


## `dockerfiles/yp-<id>-<version-id>/build`

A `build` utility will make it easy to build a local image based on the `Dockerfile`.

**NOTE** No `--help` argument exists yet. Check the sourcecode for available arguments.


## `make docker-ci`

Same images can be used locally to run `make docker-ci`
which will spin a local Docker container, to mimic the environment in which the CI pipeline runs.
We say *mimic* because there's no access to the same environment variables, or the same bind mounts.

The container will have

* a `/yplatform/docker-ci` to denote that this machine is a docker-ci one
* a bind mount of the repository, to the same location relative to `$HOME` as on the host
e.g. `/Users/andrei/git/repo` on host will be `/home/yp/git/repo` on the container
* a sudoer user with the same UID:GID as on the host, same name,
possibly same group as well (if no collision)
