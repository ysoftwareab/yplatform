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

The right amount can be fixed by going to https://github.com/settings/notifications and
* **turning off `Notifications > Automatic watching > Automatically watch repositories`**
* **turning off `Email notification preferences > Pull Request pushes`**.

The proper channels can be fixed by going to https://github.com/settings/emails
and registering your secondary email addresses, like your work address, if you haven't done so already.
Once that is done, go to https://github.com/settings/notifications#organization_routing
and select your appropriate email addresses for each organization.


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
git clone git://github.com/rokmoln/support-firecloud.git ~/git/firecloud/support-firecloud
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitignore_global
ln -s {~/git/firecloud/support-firecloud/generic/dot,}.gitattributes_global
```

If you have `git` 2.13+ and you'd like to restrict the `git` config to firecloud-related repos,
in your `~/.gitconfig` prepend AT THE TOP

```
[includeIf "gitdir:~/git/firecloud/"]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```

**NOTE** You can change the path `~/git/firecloud` accordingly, or duplicate the snippet with additional paths.

If you have an older `git` version than 2.13 or **if you'd like to use the `git` config globally**,
in all git repositories no matter if they reside under `~/git/firecloud` or elsewhere,
in your `~/.gitconfig` prepend AT THE TOP

```
[include]
    path = ~/git/firecloud/support-firecloud/generic/dot.gitconfig
```


## System

See [bootstrapping your system](../bootstrap/README.md).


## Editor

Next, [bootstrap your editor](bootstrap-your-editor.md).
