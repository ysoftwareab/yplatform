# `git` configuration

This is a sane `git` configuration based on best current practices.

## Usage

```shell
ln -s {~/git/yplatform/generic/dot,~/}.gitignore_global
ln -s {~/git/yplatform/generic/dot,~/}.gitattributes_global
```

If you have `git` version 2.13+
and you'd like to restrict the `git` config to ysoftwareab-related repos (recommended),
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/ysoftwareab/"]
    path = ~/git/ysoftwareab/yplatform/generic/dot.gitconfig
    path = ~/git/ysoftwareab/yplatform/generic/dot.gitconfig.github.com-ssh
```

**NOTE** You can change the path `~/git/yplatform` accordingly, or duplicate the snippet with additional paths.

## Older git

If you have an older `git` version than 2.13
or **if you'd like to use the `git` config globally** (not recommended),
in all git repositories no matter if they reside under `~/git/ysoftwareab` or elsewhere,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/ysoftwareab/yplatform/generic/dot.gitconfig
    path = ~/git/ysoftwareab/yplatform/generic/dot.gitconfig.github.com-ssh
```
