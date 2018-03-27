# Bootstrap your editor

We do not have a preference for an editor/IDE over the other.
You know best what works best for your flow and productivity.

We have team members using

* Emacs
* SublimeText
* Vim
* Visual Studio Code
* Webstorm IDE
* ...and more...

## editorconfig

http://editorconfig.org is a minimalist setup around text style,
like space/tab indentation, indentation size, line termination, etc.

Whatever your editor-of-choice is, it probably has built-in support or a plugin/extension
to support reading `.editorconfig` files (which we always commit to our repositories)
and set up the editor to follow the conventions for the specific file you're editing.

## Special mention: Visual Studio Code

While we do not have a preference, and we stress that wholeheartedly,
several in the team are using [Visual Studio Code](https://code.visualstudio.com/).

Therefore we may commit `.vscode` configs in our repositories,
[to notify people of certain extensions that should be installed](https://github.com/tobiipro/support-firecloud/blob/master/repo/dot.vscode/extensions.json),
or [to set up more style conventions than what editorconfig handles)(https://github.com/tobiipro/support-firecloud/blob/master/repo/dot.vscode/settings.json)
or [to set up tasks/shortcuts for generic commands relevant to each repository)(https://github.com/tobiipro/support-firecloud/blob/master/repo/dot.vscode/tasks.json).

## eslint, tslint, sasslint, etc

Part of the extensions that we want installed in Visual Studio Code deal with linting code.
When opening one of our repositories in Visual Studio code, you may be prompted to install these extensions,
and once installed you will get inline warnings/errors and maybe even automatic fixes of code style when saving a file.

If you do not use Visual Studio Code, it is in your best interest to take the time and set up your editor
to handle the relevant linting software in order to get a quick feedback cycle and keep your productivity under normal parameters,
while following agreed style conventions.
This will also help the team to stay away from redundant "typo"/"fix linting"/etc `git` commits.
