# How to license

Before making your repository public, you **MUST** choose a license.
[Why?](https://blog.codinghorror.com/pick-a-license-any-license/)

**NOTE** if you have used the [bootstrap helpers](bootstrap.md),
then you have the Apache-2.0 license by default.

## Apache-2.0

The approved and default license is ["Apache-2.0"](https://www.apache.org/licenses/LICENSE-2.0)
([local copy](../repo/LICENSE)).
[Why?](https://choosealicense.com/licenses/apache-2.0/)

A [`NOTICE`](../repo/NOTICE) file needs to be added along the `LICENSE` file.

It is good practice to have an [`AUTHORS`](../repo/AUTHORS) file also. Keep it updated!

Commit the `LICENSE`, the `NOTICE` and possibly the `AUTHORS` file to your repository,
and link to the license in `README.md` by adding at the bottom:

```md
## License

[Apache-2.0](LICENSE)
```

**NOTE** Don't forget to mention the `Apache-2.0` license in whatever package manager you use e.g. `package.json`.


## Unlicense

If the repository is really slim e.g. configuration, and thus there's nothing to protect/attribute,
then put the repository in the public domain by using ["Unlicense"](https://unlicense.org/).
[Why?](https://choosealicense.com/licenses/unlicense/)

Commit the `UNLICENSE` (not `LICENSE`) file to your repository,
and link to the license in `README.md` by adding at the bottom:

```md
## License

[Unlicense](UNLICENSE)
```

**NOTE** Don't forget to mention the `Unlicense` license in whatever package manager you use e.g. `package.json`.
