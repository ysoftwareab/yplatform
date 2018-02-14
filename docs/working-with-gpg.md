# gpg

## Bootstrapping your terminal with GPG and Keybase

A more verbose procedure is available at https://github.com/pstadler/keybase-gpg-github [local copy](ptradler-keybase-gpg-github.md).

Keybase is recommended for its simplicity and convenience but it is really optional.

```shell
# install gnu gpg suite; for example, on OSX you can run
brew cask install gpg-suite

# download the keybase app; for example, on OSX you can run
brew cask install keybase

# set up a keybase account, proofs and a gpg key

# import keybase key into gpg suite's keychain
keybase pgp export | gpg --import
keybase pgp export --secret | gpg --import --allow-secret-key-import
```

## Search for a key in Keybase and import it

```shell
keybase search <recipient>
curl https://keybase.io/<recipient>/key.asc | gpg --import -
```

## Search for a key on a pgp server and import it

```shell
gpg --search-keys <recipient>
gpg --recv <recipient-key-id>
```
