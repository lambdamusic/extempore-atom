# <img src="assets/xtm.png" width="160px">-Atom

An Atom package for
[Extempore](https://github.com/digego/extempore).  The package provides commands for interacting with a running Extempore prcess.

# Installation
This package has not been published yet. Installation instructions will be added soon.

Installation instructions for Extempore can be found at
[Extempore's github page](https://github.com/digego/extempore).

# Working with Extempore in Atom

The plugin provides three commands:

- `Connect` [alt-o] will connect to a running Extempore process at 172.0.0.1:7099 (the default port). You have to start the Extempore process yourself (in a terminal).

- `Disconnect` [alt-O or alt-x] will disconnect from the connected Extempore process.

- `Evaluate` [alt-w] will evaluate either the
  currently highlighted region (if applicable) or the current
  top-level def surrounding the cursor. This is how you send code to
  the Extempore process for evaluation.

You can trigger the commands either through the menu (`Packages >
Extempore`), or the command palette (`ctrl+shift+P`) or through the
shortcut keys (listed above).

# TODO

* Syntax Highlighting
* Expression highlighting for Evaluation
