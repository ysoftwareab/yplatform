# Secrets

## Do you really need to commit secrets?

Many times, secrets are per user, or per runtime/CI configuration.
In those cases, they probably should not be committed
but instead sourced from the environment e.g. CI secrets.


## Generic secrets

For a good balance of security and usability,
use [`transcrypt`](https://github.com/elasticdog/transcrypt) which can work with `gpg`, but doesn't have to.

**NOTE** an alternative would be [`git-crypt`](https://github.com/AGWA/git-crypt) which has a hard requirement on `gpg`.

Maybe you need to [bootstrap `gpg`](bootstrap-gpg.md)?

### Initializing a new repo

Edit/create a `.gitattributes` file in your repo
(it can be in the root and/or in a specific folder just like `.gitignore` can),
where you mark which file patterns should be considered for encryption e.g.

```
# transcrypt ===================================================================
*.cert filter=crypt diff=crypt
*.crt filter=crypt diff=crypt
*.gpg filter=crypt diff=crypt
*.key filter=crypt diff=crypt
*.secret filter=crypt diff=crypt
*.secret.* filter=crypt diff=crypt
**/*.secret/** filter=crypt diff=crypt
**/.git* !filter !diff
```

The `yplatform` repository has a version of `transcrypt` available in the `bin` folder.

Copy it to your repository and commit the executable, as it will be both safer
(in case of breaking changes) and more convenient for other users to not search
and install `transcrypt`.

```shell
cd path/to/repo
git add .gitattributes
ln -sfn yplatform/bin/transcrypt ./
git add transcrypt
git commit -m "add transcrypt"
```

Now you can initialize the repository as a `transcrypt`-ed repository:

```shell
# set up transcrypt with a randomly generated password
./transcrypt -y
./transcrypt -d
```

**NOTE** For backup purposes only, copy the output of the `./transcrypt -d` command,
and store it in a **designated safe location**. Ideally, this should only be used later as a last resort.

At this point, **you** have access to the `transcrypt`-ed repository,
but only on this local copy the repository.

Proceed to giving yourself (and others) access to all future clones of the `transcrypt`-ed repository
by following the steps in the next section.

### Giving access to a `transcrypt`-ed repository

Anyone that already has access can give someone else access to the `transcrypt`-ed repository.

This is done by **securely** sharing the encryption password,
and the recommended medium is via a `gpg` encrypted message (that is committed in the repository)
directed to a recipient (an email or a `gpg` key id).

```shell
cd path/to/repo

# check that you have a gpg public key for <user@example.com> in your local gpg keychain
# if not, see working-with-gpg.md for how to import someone's gpg public key
gpg --list-keys <user@example.com>

# export the password in an encrypted message for <user@example.com>
./transcrypt --export-gpg <user@example.com>

# commit the encrypted message
mkdir -p .transcrypt
cp $(ls -t $(git rev-parse --git-dir)/crypt/*@example.com.asc | head -n1) .transcrypt/
git add .transcrypt
git commit -m "add transcrypt recipient"
```

### Working with a `transcrypt`-ed repository

```shell
cd path/to/repo
make decrypt

# ./transcrypt -y --import-gpg .transcrypt/<yourself@example.com>.asc
```

When finished working with the secrets, flush (remove) credentials `./transcrypt -y -f`.

**NOTE** In extreme situations, if nobody can decrypt `.transcrypt/*.asc`,
use the **designated safe location** to run `./transcrypt -c <cipher> -p <password>`
and restore access to the transcrypt-ed repo.

Working with secrets is probably a very seldom and time-limited task.
So whenever you have finished the task, **remember to flush transcrypt crendentials**
i.e. remove the transcrypt password and also re-encrypt all files at rest,
in order to minimize the risk of leaking the secrets.
