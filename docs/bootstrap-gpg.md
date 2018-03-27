# gpg

## Bootstrapping your terminal with `gpg` and `keybase`

```shell
# install gnu gpg suite; for example, on OSX you can run
brew cask install gpg-suite
```

**FOLLOW THE INSTRUCTIONS IN** https://github.com/pstadler/keybase-gpg-github
([local copy](pstradler-keybase-gpg-github.md)).
Use `Method 2` in `Optional: In case you're prompted to enter the password every time`.

**NOTE** `keybase` is recommended for its simplicity and convenience but it is really optional.

```shell
# download the keybase app; for example, on OSX you can run
brew cask install keybase

# set up a keybase account, proofs and a gpg key

# import keybase key into gpg suite's keychain
keybase pgp export | gpg --import
keybase pgp export --secret | gpg --import --allow-secret-key-import
```


## Search for a key in `keybase` and import it

```shell
keybase search <recipient>
curl https://keybase.io/<keybase_username>/key.asc | gpg --import -
```


## Search for a key on a `pgp` server and import it

**NOTE** recipient = an email or a gpg key id

```shell
gpg --search-keys <recipient>
gpg --recv <recipient-key-id>
```
