# Bootstrap

**NOTE** All documentation here refers to `~/git/yplatform` as the home of yplatform.
You can chose any folder you like, but then you'll have to pay attention every time you might copy-paste
some instruction from our documentation. If you still want to use another folder, you could consider at least
symlinking `~/git/yplatform` to the folder of your choice, so copy-pasting would still work.


```shell
cd # make sure that you are at home dir (~)
git clone https://github.com/ysoftwareab/yplatform.git ~/git/yplatform
```


# Bootstrap your system

We support MacOS, Linux and Microsoft Windows (WSL) platforms.
MacOS is the main development platform, while Linux (Ubuntu) is the main CI/CD platform.

If you find yourself developing on Microsoft Windows,
[you can setup WSL as your development platform](README.wsl.md).


## GNU

In order to simplify our ~scripts~ lives, we expect GNU binaries, even on MacOS.

We hear you: but wouldn't it be possible to support BSD (MacOS) alternatives?
More like [unpossible](https://ponderthebits.com/2017/01/know-your-tools-linux-gnu-vs-mac-bsd-command-line-utilities-grep-strings-sed-and-find/)
because it's not enough to keep yourself to a POSIX common denominator, or to be a great Unix programmer,
but you really have to know and watch out for cornercases
driven by differences in implementation between GNU and BSD versions,
and that means everyone has to be that person.

We hear you again: will that not screw up other software on my computer expecting BSD behavior of `find`, `sed`, `grep`, etc?
If software depends on BSD behavior on MacOS, then they **SHOULD** use the full path e.g. `/usr/bin/find` instead of `find`.
Chances are in the 99%-realm high that everything will work just fine.


## Installation

Developer system dependencies can be installed by

1. appending to your `~/.bashrc` (or `~/.bash_profile`), `~/.zshrc`, etc.:

```shell
# keep the next line as the last line in your shell rc/profile file
source ~/git/yplatform/sh/dev.inc.sh
```

2. restarting your shell

3. running `~/git/yplatform/dev/bootstrap`

**NOTE** You can also try to bootstrap without using `sudo`.
Run `YP_SUDO=yp_nosudo ~/git/yplatform/dev/bootstrap` instead.

4. testing that everything is fine by checking that running `echo $YP_DEV` prints `true`.

Continue to bootstrap

* [your editor](README.editor.md)
* [Github](README.github.md)
* [AWS (console and CLI)](README.aws.md) (optional)
* [your `gpg` signature](README.gpg.md) (optional)


## Customization via environment variables

Here's a list of the environment variables that customize the code execution:

* `YP_LOG_BOOTSTRAP`
  * set to `true` to enable printing the whole bootstrap log which is hidden by default
* `YP_PRINTENV_BOOTSTRAP`
  * set to `true` to enable printing all environment variables
* `YP_SKIP_BREW_UNINSTALL`
  * set tot `true` to skip uninstalling Homebrew
* `YP_SKIP_BREW_BOOTSTRAP`
  * set to `true` to skip brew bootstrapping `bootstrap/brew-bootstrap.inc.sh`
* `YP_SKIP_SUDO_BOOTSTRAP`
  * set to `true` to skip sudo bootstrapping `bootstrap/<OS_SHORT>/bootstrap-sudo`
* `YP_SUDO`
  * set to `yp_nosudo` to bootstrap without sudo
  * set to a custom `sudo` executable path


## Repository

Repositories might require more system dependencies e.g. `electron` or `erlang` or `go`.

These are defined in a file called `Brewfile.inc.sh` within each repository.

Run `make bootstrap` to install them.
