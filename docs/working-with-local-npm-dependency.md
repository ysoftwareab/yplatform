# Working with a local NPM dependency

At times, in your development process, you may have an NPM package `bar`
has a dependency on another NPM package `foo`, that you also develop.

In such cases, you want a quick feedback loop.
Make changes in `foo`, build, try out the changes in `bar`.

Here follows a solution to do exactly that with npm v5 and newer.
If you do not have the correct npm version, you can upgrade your global npm via `npm i -g npm`.

## start working with the local dependency

```shell
cd path/to/bar
cat package.json | grep foo # shows smth like <"foo": "1.0.0">
npm i path/to/local/foo
```

## explanation

```shell
cd path/to/bar
ls -l node_modules | grep foo # shows a symlink <node_modules/foo -> path/to/local/foo>
git status                    # shows that package.json has changed
cat package.json | grep foo   # shows smth like <"foo": "file:path/to/local/repo"
```

**NOTE** while obvious for many, this change in `package.json` should never be committed.

**NOTE** having a dirty `package.json` is very nice for two reasons: you don't have to worry
that `npm i` would somehow revert your changes, and you also have a glarying git modification
that tell you that you should undo the local-development setup.


## stop working with the local dependency

```shell
cd path/to/bar
git checkout package.json
cat package.json | grep foo   # shows smth like <"foo": "1.0.0">
make                          # or npm i, etc will remove the symlink and unzip a regular package
ls -l node_modules | grep foo # shows a regular folder <node_modules/foo>
```
