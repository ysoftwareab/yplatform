# Bootstrap Github

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

* generate SSH key/s, if you didn't already
  * [see local instructions](../dot.ssh/config)
  * [alternatively see github's instructions](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
* [add SSH key/s to your Github account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account)
* configure your `~/.ssh/config` as per [local instructions](../dot.ssh/config)

You also need to click "Enable SSO" at https://github.com/settings/keys for your SSH key,
if you are part of an organization behind SSO.

Same goes for "Personal access tokens",
if you will ever need them to work with your organization: https://github.com/settings/tokens .
