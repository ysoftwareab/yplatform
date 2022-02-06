# SSH config

Contents:

* [config](./config)
* [config.github](./config.github)
* [known_hosts.github](./known_hosts.github)

This is a hardened SSH config based on

* https://infosec.mozilla.org/guidelines/openssh#OpenSSH_client#key-generation
* https://infosec.mozilla.org/guidelines/openssh#OpenSSH_client#openssh-client
* https://stribika.github.io/2015/01/04/secure-secure-shell.html
* https://github.com/dolmen/github-keygen

## Usage

```shell
mkdir -p ${HOME}/.ssh
chmod 700 ${HOME}/.ssh

# Create a symlink ~/.ssh/yplatform to this README's folder e.g. path/to/yplatform/sshconfig
ln -sfn path/to/yplatform/sshconfig ~/.ssh/yplatform

# NOTE as per ssh_config manual: "the first obtained value for each parameter is used".
# Append these lines to ~/.ssh/config and they will act as default values:
# Include ~/.ssh/yplatform/config
grep -q "^Include ~/\.ssh/yplatform/config$" ~/.ssh/config || \
  echo "Include ~/.ssh/yplatform/config" > ~/.ssh/config
```

## Generate new SSH keys

```shell
mkdir -p ${HOME}/.ssh
chmod 700 ${HOME}/.ssh
ssh-keygen -f ${HOME}/.ssh/id_ed25519 -q -N "" -C "$(whoami)@$(hostname)" -a 100 -t ed25519
```

Optionally generate a less-secure RSA key for legacy systems
`ssh-keygen -f ${HOME}/.ssh/id_rsa -q -N "" -C "$(whoami)@$(hostname)" -a 100 -t rsa -b 4096`.

Optionally use your email address instead of `$(whoami)@$(hostname)`.

Optionally add a suffix to the `id_*` file, like `.<scope>.$(date +%Y-%m-%d)`,
where `<scope>` can be `home`, `work`, `github`, `gitolite`, etc.

Optionally run `ssh-add ${HOME}/.ssh/id_*`.
