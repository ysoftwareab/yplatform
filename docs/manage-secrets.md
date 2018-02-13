# Secrets

## Do you really need to commit secrets?

Many times, secrets are per user, or per runtime/CI configuration.
In those cases, they probably should not be committed
but instead sourced from the environment e.g. see below "Travis CI secrets".


## Generic secrets

For a good balance of security and usability,
use https://github.com/elasticdog/transcrypt which can work with gpg, but doesn't have to.

**NOTE** An alternative would be https://github.com/AGWA/git-crypt which has a hard requirement on gpg.

[See here on how to bootstrap your terminal with GPG and optionally with Keybase](bootstrap-gpg.md).

### Bootstrapping a new repo

The `support-firecloud` repo has a version of transcrypt available in the `bin` folder.

Copy it to your repo and commit the executable, as it will be both safer
(in case of breaking changes) and more convenient for other users to not search
and install transcrypt.

```shell
cd path/to/git/repo
cp path/to/support-firecloud/bin/transcrypt ./
git add transcrypt
git commit -m "add transcrypt executable"
```

Now you can initialize the repo as a transcrypt-ed repo:

```shell
# set up transcrypt with a randomly generated password
./transcrypt -y
```

**NOTE** For backup purposes only, copy the output of the `./transcrypt -y` command,
and store it in a **designated safe location**. Ideally, this should only be used later as a last resort.

At this point, **you** have access to the transcrypt-ed repo, but only on this local copy the repo.

Proceed to giving yourself (and others) access to all future clones of the transcrypt-ed repo
by following the steps in the next section.

### Giving access to a transcrypt-ed repo

Anyone that already has access can give someone else access to the transcrypt-ed repo.

This is done by **securely** sharing the encryption password,
and the recommended medium is via a gpg encrypted message (that is committed in the repo)
directed to a recipient (an email or a gpg key id).

```shell
cd path/to/git/repo

# check that you have a gpg public key for <recipient> in your local gpg keychain
# if not, see working-with-gpg.md for how to import someone's gpg public key
gpg --list-keys <recipient>

# export the password in an encrypted message for <recipient>
./transcrypt --export-gpg <recipient>

# commit the encrypted message
mkdir -p .transcrypt
cp $(git rev-parse --git-dir)/crypt/*.asc .transcrypt/
git add .transcrypt
git commit -m "add transcrypt recipient"
```

### Working with a transcrypt-ed repo

```shell
cd path/to/git/repo
./transcrypt --import-gpg .transcrypt/<yourself>.asc
```

**NOTE** In extreme situations, if nobody can decrypt `.transcrypt/*.asc`, use the **designated safe location**
to run `./transcrypt -c <cipher> -p <password>` and restore access to the transcrypt-ed repo.


## Travis CI secrets

If your repo is hosted on github.com and your CI environment of choice is Travis CI,
and you have Travis-specific values to encrypt e.g. a Slack API token for notifications,
then you can add encrypted values in the `.travis.yml` file.

You can simply use the `bin/travis-encrypt` shell script utility in the `support-firecloud` repo
and shortcircuit the official [`Travis CI` client](https://github.com/travis-ci/travis.rb) which requires Ruby&co.

```shell
path/to/support-firecloud/bin/travis-encrypt --value something_super_secret
```

Now you can add the `secret: "..."` text to your `.travis.yml` file.

### Transcrypt-ed repo

If your repo is transcrypt-ed, and you want to access secret in Travis CI, the follow these steps:

```shell
cd path/to/git/repo
path/to/support-firecloud/bin/travis-encrypt --value "./transcrypt -y -c <cipher> -p <password>"
```

Now you can add the `secret: "..."` text to your `.travis.yml` file as the first item within `before_install:`.
