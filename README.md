# support-firecloud

Support files  (e.g. configuration like `.gitconfig`, `.editorconfig`).

## git settings

**NOTE** We assume that you keep all firecloud-related git repos under `~/git/firecloud`.
Failing to do so, hell won't break loose, but you are on your own.

```shell
cd ~/git/firecloud
git clone git@git.tobii.intra:cloud/an/firecloud/support-firecloud.git

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


## Repository-specific settings

Use as a git submodule via

```shell
git submodule add support/firecloud git@git.tobii.intra:cloud/an/firecloud/support-firecloud.git
ln -s {support/firecloud/repo/dot,}.editorconfig
ln -s {support/firecloud/repo/dot,}.npmrc
ln -s {support/firecloud/repo/dot,}.vscode
```

or as an npm dependency via

```shell
npm install --save-dev --save-exact git@git.tobii.intra:cloud/an/firecloud/support-firecloud.git#commitish
ln -s {node_modules/support-firecloud/dot,}.editorconfig
ln -s {node_modules/support-firecloud/dot,}.npmrc
ln -s {node_modules/support-firecloud/dot,}.vscode
```
