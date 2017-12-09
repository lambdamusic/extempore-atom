# <img src="https://raw.githubusercontent.com/noahingham/extempore-atom/master/assets/xtm-atom.png" width="350px" alt="Extempore-Atom">

An Atom package for
[Extempore](https://github.com/digego/extempore), providing syntax highlighting, snippets and commands for working with Extempore.


# Notes about this fork

I forked this project from [noahingham](https://github.com/noahingham/extempore-atom) and made a whole bunch of changes based on my livecoding preferences (e.g. see [snippets](https://github.com/lambdamusic/extempore-atom/tree/master/snippets) and [grammars](https://github.com/lambdamusic/extempore-atom/tree/master/grammars)). Not sure it'll be of use to anybody else, but feel free to have a look around.

If you're just starting out with Extempore it's probably better to use [noahingham](https://github.com/noahingham/extempore-atom) original atom-extempore release of the plugin. 

Have fun!

# Installation
Extempore-Atom can be installed through the Atom settings or by running `apm install extempore-atom` in a terminal / command prompt.

Installation instructions for Extempore can be found at
[Extempore's github page](https://github.com/digego/extempore).

# Working with Extempore in Atom

See [Ben Swift's guide](http://benswift.me/2016/02/15/extempore-atom-cheat-sheet/) for a cheat sheet for using Atom with Extempore.

The plugin provides three commands:

- `Connect` [alt-o] will connect to a running Extempore process at the host and port specified in the input box. You have to start the Extempore process yourself (see Extempore docs for how to do this).

- `Disconnect` [alt-O or alt-x] will disconnect from the connected Extempore process.

- `Evaluate` [alt-s] will evaluate either the
  currently highlighted region (if applicable) or the current
  top-level expression surrounding the cursor. This is how you send code to
  the Extempore process for evaluation.

You can trigger the commands either through the menu (`Packages >
Extempore`), the command palette (`ctrl+shift+P`) or through the
shortcut keys (listed above).

# Preview

![Extempore-Atom preview](https://raw.githubusercontent.com/noahingham/extempore-atom/master/assets/xtm-atom-eg.gif)
