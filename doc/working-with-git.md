# git (and Github)

## Github onboarding

* Have an account? If not [register one](https://github.com/join).
  * Register with your personal email, if possible. You will surely have a Github account beyond your stay at Tobii.
* Go to https://github.com/settings/profile and fill in some info and **upload a picture**.
* Go to https://github.com/settings/emails and **register your @tobii.com email address**.
  * Keep the personal one as the primary one.
* Go to https://github.com/settings/security and **enable Two-factor**.
* Follow the instructions below and **setup [Github notifications](#github-notifications)**.


## Github notifications

Notifications are nice, and even necessary to have,
but they need to come in the right amount and on proper channels.

The right amount can be fixed by going to https://github.com/settings/notifications
and **turning off `Automatically watch repositories`**.

The proper channels can be fixed by going to https://github.com/settings/emails
and registering your @tobii.com email address, if you haven't done so already.
Once that is done, go to https://github.com/settings/notifications#organization_routing
and select the @tobii.com email address for the Tobii organizations.


## Feature branches

We use a convention of prefixing feature branches with `f/`.
The term `feature` is overloaded, as it means any topic e.g. `bug`, `emergency-fix`, `user`, etc.

This allows different systems, like the CI/CD, to make certain decisions based on the name of the branch.

One sensible thing to do further is to have your branches start with a unique indicative,
like your username e.g.

* GOOD `f/anu-add-logo` (`anu` is my username)
* GOOD `f/add-logo`
* DONT `add-logo`


## New repositories

See [New git (and Github) repositories](./working-with-git-new.md).
