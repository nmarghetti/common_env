# Common env ![Build](https://github.com/nmarghetti/common_env/workflows/Build/badge.svg)

## Description

This project aim to facilitate the setup of a common environment for people with completely different computer skills (developper, tester, business analyst, etc.). It's first part facilitate a common usage of GIT and python for **Linux**, **macOS** and **Windows**. The second part, for Windows users, is focused on installing a portable tools environment.

1. **Common core**

   - **Git**: common configuration and aliases to simplify GIT usage
   - **Python**: brings a simple way to create, list and switch between several python environments (eg. between python 2.x 3.x)

1. **Windows**

For Windows user it also brings a portable environment thanks to [PortableApps](https://portableapps.com/) with a huge catalog of applications. On top of it, it installs and configure **Git for Windows** (Git-bash), **Visual Studio Code** and more.

## Setup

1. Linux or macOS

   The common setup is as easy as follow:

   ```bash
   # Clone the repository
   git clone https://github.com/nmarghetti/common_env.git

   # Run the setup
   bash ./common_env/scripts/setup.sh
   ```

1. Windows

   - If you only want what is above you can do the same as far as you have git and bash installed. For example open Bash on Ubuntu On windows, WSL or Git-bash and run the same 2 commands above for Linux or macOS.
   - Otherwise, for a more advanced setup to get a more complete and portable development environment, follow this [**WINDOWS SETUP GUIDE**](readme/README_setup.md).

## Features

1. **Common core**

   The common part works for the following environment:

   - Linux via bash or zsh
   - macOS via bash or zsh
   - Windows
     - [WSL](https://docs.microsoft.com/en-gb/windows/wsl/install-win10) (Windows Subsystem for Linux)
     - [Bash on Unbuntu on Windows](https://ubuntu.com/wsl) (that requires WSL)
     - Powershell by invoking wsl or bash (requires the corresponding one above)

   Either you are on **Windows**, **Linux** or **macOS** and using **bash** or **zsh**, you would get:

   - **Python** virtual environment easy to handle with few simple shell functions:
     - **pylist**: list your available python venv
     - **pycreate** [python_path][version]: create a venv name _version_ with python from _python_path_
     - **pyset** version: activate the venv _version_ (it has to exist from list given by "pylist")
     - **pyunset**: deactivate current venv
   - **Git** configured with some core settings and many useful aliases
     - core settings about whitespace, EOL, filemode, symlinks, long path, etc.
     - main coloration
     - many aliases to handle several usecases and for each it displays the full real git command invoked

1. **macOS**

   On macOs it will also install some extra package to have necessary GNU tools such as readlink, awk, sed, etc.

1. **Windows**

If you are on Windows, you can get a portable development environment (it is not hardly installed in the system, all the applications are portable) with the following tools especially configured:

- **Visual Studio Code** with several extensions
- **Git for Windows** (Git-bash)
- **Python** (3.8)
- **Node.js**
- C/C++ tools: **CMake**, **GCC**

You could optionnally get a bunch of other applications from [PortableApps](https://portableapps.com/):

- Notepad++
- Google Chrome
- Mozilla Firefox
- PuTTY
- 7-Zip
- Process Explorer
- etc.

Visual Studio Code and the other tools are configured to work together. It brings a common configuration between developpers to ensure to format source code, configuration file or even README the same way.\
Each developper can contribute to the tools and everyone would benefit from it.\
Any developper could join and install quickly everything like the others with only few simple steps.

## Usefull links

1. **Git**

   - Git for Windows: [https://git-scm.com](https://git-scm.com/)
   - Documentation: [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2)

1. **Python**

   - Python: [https://www.python.org](https://www.python.org/)
   - Documentation: [Python2.7](https://docs.python.org/2.7/) / [Python 3.x](https://docs.python.org/3/)

1. **Others**
   - Visual Studio Code Portable mode: [https://code.visualstudio.com/docs/editor/portable](https://code.visualstudio.com/docs/editor/portable)
   - PortableApps: [https://portableapps.com](https://portableapps.com/)
