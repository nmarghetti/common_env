# Common env

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0bf097505ea14121b1fa979f9f5c66af)](https://www.codacy.com/gh/nmarghetti/common_env/dashboard?utm_source=github.com&utm_medium=referral&utm_content=nmarghetti/common_env&utm_campaign=Badge_Grade)
![Build](https://github.com/nmarghetti/common_env/workflows/Build/badge.svg)

---

<!-- TOC depthFrom:2 -->

- [Description](#description)
- [Setup](#setup)
  - [Portable environment for Windows](#portable-environment-for-windows)
  - [Common configuration only](#common-configuration-only)
- [Features](#features)
- [Git](#git)
- [Cmder](#cmder)
  - [Cmder shortcuts](#cmder-shortcuts)
- [AutoHotkey](#autohotkey)
  - [AutoHotkey shorcuts](#autohotkey-shorcuts)
- [Usefull links](#usefull-links)

<!-- /TOC -->

---

## Description

This project aim to facilitate the setup of a common environment for people with completely different computer skills (developper, tester, business analyst, etc.). It's first part facilitate a common usage of GIT and python for **Linux**, **macOS** and **Windows**. The second part, for Windows users, is focused on installing a portable tools environment.

1. **Common core**

   - **Git**: common configuration and aliases to simplify git usage, check this [**_GIT GUIDE_**](readme/README_git_guide.md).
   - **Python**: brings a simple way to create, list and switch between several python environments (eg. between python 2.x 3.x)

1. **Windows**

For Windows user it brings a portable environment with several applications already configured and integrated in [PortableApps](https://portableapps.com/) which also offer a huge catalog of other portable applications. Check the Features section to know more.

## Setup

### Portable environment for Windows

Download [**setup.cmd**](https://raw.githubusercontent.com/nmarghetti/common_env/master/tools/setup.cmd) and [setup.ini](https://raw.githubusercontent.com/nmarghetti/common_env/master/tools/setup.ini) (Right click -> "Save Link As...") into a folder preferably with no space (eg. "C:\PortableEnv"), execute setup.cmd and follow the instruction written in the terminal.

```text
C:/PortableEnv
├── setup.cmd
└── setup.ini
```

Check this [**installation guide**](readme/README_setup.md) for more details.

### Common configuration only

The common setup is as easy as follow:

```bash
# Clone the repository
git clone https://github.com/nmarghetti/common_env.git

# Run the setup
./common_env/scripts/setup.sh
```

## Features

1. ### **Common core**

   The common part works for the following environment:

   - Linux via bash or zsh
   - macOS via bash or zsh
   - Windows
     - [WSL](https://docs.microsoft.com/en-gb/windows/wsl/install-win10) (Windows Subsystem for Linux)
     - [Bash on Unbuntu on Windows](https://ubuntu.com/wsl) (that requires WSL)
     - Powershell by invoking wsl or bash (requires the corresponding one above)

   Either you are on **Windows**, **Linux** or **macOS** and using **bash** or **zsh**, you would get:

   - **Python** virtual environment easy to handle with few simple shell functions:
     - **pyinfo**: display information about the current python in use
     - **pylist**: list your available python venv
     - **pycreate** [python_path][version]: create a venv name _version_ with python from _python_path_
     - **pyset** version: activate the venv _version_ (it has to exist from list given by "pylist")
     - **pyunset**: deactivate current venv
   - **Git** configured with some core settings and many useful aliases
     - core settings about whitespace, EOL, filemode, symlinks, long path, etc.
     - main coloration
     - many aliases to handle several usecases and for each it displays the full real git command invoked

1. ### **macOS**

   On macOs it will also install some extra package to have necessary GNU tools such as readlink, awk, sed, etc.

1. ### **Windows portable env**

If you are on Windows, you can get a portable development environment (it is not hardly installed in the system, all the applications are portable) with the following tools especially configured:

- **Visual Studio Code** (~250M) with several extensions
- **Git for Windows** (~280M)
  - tools: **curl**, **rsync**, **tree**, **wget** (~6M)
  - **pacman** package manager (~50M) and additional packages:
    - **man** (~130M)
    - **zsh**
    - **tmux**
    - **make**, **cmake**, **mingw-w64-x86_64-toolchain** for C/C++ dev (~1G)
- **PyCharm** (~700M)
- **PuTTY** (~5M)
- **Cmder** (~30M)
- **MobaXterm** (~13M)
- **SuperPuTTY** (~2M)
- **Tabby** (~300M)
- **Python** (2.7)
- **Python** (3.8) (~50M)
- **Java SDK** (15) (~300M)
- **Node.js** (~65M)
- **nvm** (~120K)
- **Gradle** (~110M)
- **Elastic ELK stack (Elasticsearch, Logstash, Kibana)** (~1.7G)
- **Cygwin**
- **XAMPP**
- **WSL** (Install and configure Ubuntu-20.04)

You could optionnally get a bunch of other applications from [PortableApps](https://portableapps.com/):

- Notepad++
- Google Chrome
- Mozilla Firefox
- 7-Zip
- Process Explorer
- etc.

Visual Studio Code and the other tools are configured to work together. It brings a common configuration between developpers to ensure to format source code, configuration file or even README the same way.\
Each developper can contribute to the tools and everyone would benefit from it.\
Any developper could join and install quickly everything like the others with only few simple steps.

## Git

If you are looking for an easy way to start with Git, you can follow [**this guide**](readme/README_git_guide.md).

You can define those environment variables to customize git:

- GIT_CMD_NOCOLOR=1 to not display real git command for aliases in color (as it can be a bit slow)
- GIT_CMD_NOECHO=1 to not display real git command for aliases

## Cmder

### Cmder shortcuts

1. Tasks

   - alt+shift+1: open task 1 --> open Git-bash
   - alt+shift+2: open task 2 --> ssh remote machine 1
   - etc.

1. Split screen

   - ctrl+alt+right arrow: split vertically
   - ctrl+alt+down arrow: split horizontally
   - ctrl+shift+arrow (up, down, left, right): change the focus to the terminal of the arrow direction
   - ctrl+alt+shift+arrow (up, down, left, right): increase the size of the current terminal in the arrow direction

1. Tabs

   - ctrl+tab: focus on next tab on the right
   - ctrl+shift+tab: focus on next tab on the left
   - win+alf+arrow (left, right): move the current tab to the arrow direction

## AutoHotkey

### AutoHotkey shorcuts

- Win + !: switch ON/OFF current window always on top
- Win + Shift + Up arrow: maximize current window among all similar monitors
- Win + Shift + Down arrow: maximize current window in only one monitor

## Usefull links

1. **Git**

   - [Git for Windows](https://git-scm.com/), [Git command description](https://git-scm.com/docs/git), [Git cheatsheet](https://ndpsoftware.com/git-cheatsheet.html)
   - [Reference Manual](https://git-scm.com/docs), [Pro Git online book](https://git-scm.com/book/en/v2), [Tutorials](https://git-scm.com/doc/ext)

1. **Python**

   - [Homepage](https://www.python.org/)
   - Documentation: [Python2.7](https://docs.python.org/2.7/) / [Python 3.x](https://docs.python.org/3/)
   - [Pip](https://pip.pypa.io/en/stable/reference/pip_config/)
   - Portable Python packaging
     - PortablePython (not developped anymore): [homepage](https://portablepython.com/), [download](https://portablepython.com/wiki/Download/)
     - [WinPython](http://winpython.github.io/)
     - [PythonAnywhere](https://www.pythonanywhere.com/)
   - Other Python packaging
     - [Anaconda](https://www.anaconda.com/distribution/)
     - [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
     - [Python(x-y)](http://python-xy.github.io/)

1. **Visual Studio Code**

   - [Portable mode](https://code.visualstudio.com/docs/editor/portable)
   - [Setup network](https://code.visualstudio.com/docs/setup/network)
   - [Command Line Interface](https://code.visualstudio.com/docs/editor/command-line)

1. **PortableApps**

   - [Homepage](https://portableapps.com/)
   - [App setting](https://portableapps.com/development/portableapps.com_format#appinfo)

1. **Xterm**

   - [PuTTY](https://www.putty.org/)
   - [SuperPutty](https://github.com/jimradford/superputty)
   - [Cmder](https://cmder.net/): [ConEmu](https://conemu.github.io/), [Clink](https://mridgers.github.io/clink/)
   - [MobaXterm](https://mobaxterm.mobatek.net/)
   - [tmux](https://github.com/tmux/tmux/): [info](https://github.com/rothgar/awesome-tmux), [config](https://github.com/gpakosz/.tmux)
   - [mintty](https://mintty.github.io/): [doc](https://mintty.github.io/mintty.1.html)
   - [Tabby](https://tabby.sh/)

1. **Other**

   - [Bash/Unix/Linux tutorial](https://www.tutorialspoint.com/unix_commands/bash.htm)
   - Bash: [Reference manual](https://www.gnu.org/software/bash/manual/html_node/index.html#SEC_Contents), [style](https://github.com/progrium/bashstyle), [obsolete](https://wiki.bash-hackers.org/scripting/obsolete), [cheatsheet](https://bertvv.github.io/cheat-sheets/Bash.html), [parse args](https://unix.stackexchange.com/questions/62950/getopt-getopts-or-manual-parsing-what-to-use-when-i-want-to-support-both-shor), [ArgBash](https://argbash.io/send_template#generated), [Parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html), [set](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
   - [Bash-it](https://github.com/Bash-it/bash-it): [doc](https://bash-it.readthedocs.io/en/latest/themes-list/)
   - [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
   - [Batch tutorial](https://www.tutorialspoint.com/batch_script/index.htm), [help](https://ss64.com/nt/)
   - [Cygwin](https://cygwin.com/): [Portable Cygwin](https://github.com/vegardit/cygwin-portable-installer)
   - Pacman: [homepage](https://www.archlinux.org/pacman/), [documentation](https://www.archlinux.org/pacman/pacman.8.html), [wiki](https://wiki.archlinux.org/index.php/pacman)
