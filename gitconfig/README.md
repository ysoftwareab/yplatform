# `git` configuration

```shell
ln -s {~/git/support-firecloud/generic/dot,~/}.gitignore_global
ln -s {~/git/support-firecloud/generic/dot,~/}.gitattributes_global
```

If you have `git` 2.13+ and you'd like to restrict the `git` config to firecloud-related repos,
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/firecloud/"]
    path = ~/git/support-firecloud/generic/dot.gitconfig
```

**NOTE** You can change the path `~/git/firecloud` accordingly, or duplicate the snippet with additional paths.

If you have an older `git` version than 2.13 or **if you'd like to use the `git` config globally**,
in all git repositories no matter if they reside under `~/git/firecloud` or elsewhere,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/support-firecloud/generic/dot.gitconfig
```
