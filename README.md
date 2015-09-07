# Extempore-Atom

An Atom package for
[Extempore](https://github.com/digego/extempore).  The package provides commands for interacting with a running Extempore process.

# Installation
This package has not been published yet. Installation instructions will be added soon.

Installation instructions for Extempore can be found at
[Extempore's github page](https://github.com/digego/extempore).

# Working with Extempore in ST

The plugin provides three commands:

- `Connect` will connect to a running Extempore process at 172.0.0.1:7099 (the default port). You have to start the Extempore process yourself (in a terminal).

- `Disconnect` will disconnect from the connected Extempore process.

- `Evaluate` will evaluate either the
  currently highlighted region (if applicable) or the current
  top-level def surrounding the cursor. This is how you send code to
  the Extempore process for evaluation.

You can trigger the commands either through the menu (`Tools >
Extempore`), or the command palette (`ctrl+shift+P`) or through the
shortcut keys (listed above).

![Atom packaging](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
