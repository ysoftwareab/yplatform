# Bootstrap

## Github onboarding

* Have an account? If not [register one](https://github.com/join).
  * Register with your personal email, if possible, and not your company email.
* Go to https://github.com/settings/profile and fill in some info and **upload a picture**.
* Go to https://github.com/settings/emails and **register your work email address**.
  * Keep the personal one as the primary one.
* Go to https://github.com/settings/security and **enable Two-factor**.
* Follow the instructions below and **setup [Github notifications](#github-notifications)**.


## Github notifications

Notifications are nice, and even necessary to have,
but they need to come in the right amount and on proper channels.

The right amount can be fixed by going to https://github.com/settings/notifications
and **turning off `Automatically watch repositories`**.

The proper channels can be fixed by going to https://github.com/settings/emails
and registering your work email address, if you haven't done so already.
Once that is done, go to https://github.com/settings/notifications#organization_routing
and select the work email address.


## Add your SSH key to your Github account

We access repositories via SSH (not HTTPS), so you need to

* [set up an SSH key](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), if you don't have one already
* [and add it to your Github account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account)

You also need to click "Enable SSO" at https://github.com/settings/keys for your SSH key.

## `git`

We assume that you keep all firecloud-related `git` repositories under `~/git/firecloud`.

*Failing to do so, hell won't break loose, but you are on your own.
As long as you store the firecloud-related `git` repositories in one folder e.g. `~/Documents/Firecloud`,
you can easily create a symlink `ln -s ~/Documents/Firecloud ~/git/firecloud` and keep everyone happy.*


```shell
cd # make sure that you are at home dir (~)
git clone git@github.com:rokmoln/support-firecloud.git ~/git/firecloud/support-firecloud
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitignore_global
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitattributes_global
```

If you have `git` 2.13+ and you'd like to restrict the `git` config to firecloud-related repos,
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/firecloud/"]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

Alternatively, either for earlier `git` versions or if you'd like to use the `git` config globally,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

## System

We support Darwin (OSX) and Linux (Ubuntu) architectures.
The former is the main development architecture, while the latter is the main CI/CD architecture.

**We do NOT support Windows Subshell for Linux**, but we do know that it is possible to successfully bootstrap Ubuntu 16.04/18.04 distributions under it. If you feel adventurous, read and improve our experimental notes on [working with WSL](working-with-wsl.md).

**NOTE** In order to [simplify our ~scripts~ lives](https://ponderthebits.com/2017/01/know-your-tools-linux-gnu-vs-mac-bsd-command-line-utilities-grep-strings-sed-and-find/),
we expect GNU binaries (even on Darwin).

All common system-wide dependencies can be installed by running

```shell
~/git/firecloud/support-firecloud/dev/bootstrap
```

You can also try to bootstrap without using `sudo`.
Run `SUDO=sf_nosudo ~/git/firecloud/support-firecloud/dev/bootstrap` instead.

**NOTE** If the bootstrap script above didn't finish by printing `Restart your shell, and you're good to go.`,
then you know the script has failed while executing.

**IMPORTANT. THE ONLY MANUAL STEP**
is to append to your `~/.bashrc` (or `~/.bash_profile`), `~/.zshrc`, etc.:

```shell
# keep the next line as the last line in your shell rc/profile file
source ~/git/firecloud/support-firecloud/sh/dev.inc.sh
```

Restart your shell, and you're good to go.

**NOTE** You can test that everything is fine by checking that running `echo $SF_DEV_INC_SH` prints `true`.

**NOTE** Repositories might require more system-wide dependencies.
These are defined in a file called `Brewfile.inc.sh` within each repository.
To install them, run `make bootstrap` inside the repository.
You can also run `make bootstrap/scratch` to (re)install both common and repository-specific ones.


## Editor

Next, [bootstrap your editor](bootstrap-your-editor.md).
