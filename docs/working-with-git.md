# git

## settings

**NOTE** We assume that you keep all firecloud-related git repos under `~/git/firecloud`.
Failing to do so, hell won't break loose, but you are on your own.

```shell
cd
git clone git@github.com:tobiipro/support-firecloud.git ~/git/firecloud/support-firecloud
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitignore_global
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitattributes_global
```

If you have git 2.13+ and you'd like to restrict the git config to firecloud-related repos,
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/firecloud/"]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

Alternatively, either for earlier git versions or if you'd like to use the git config globally,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```
