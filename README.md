# Common env ![Build](https://github.com/nmarghetti/common_env/workflows/Build/badge.svg)

## Description

Either you are on **Windows**, **Linux** or **macOs** and using **bash** or **zsh**, you would get:

- **Python** virtual environment easy to handle with few simple shell simple functions:
  - **pylist**: list the your available python venv
  - **pycreate** [python_path][version]: create a venv name _version_ with python from _python_path_
  - **pyset** version: activate the venv _version_ (it has to exist from list given by "pylist")
  - **pyunset**: deactivate current venv
- **Git** configured with some core settings and many useful aliases
  - core settings about whitespace, EOL, filemode, symlinks, long path, etc.
  - main coloration
  - many aliases that display the real git command when invoked for several case

If you are on **Windows**, you can get a portable development environment (it is not hardly installed in the system, all the applications are portable) with the following tools:

- **Visual Studio Code** with several extensions
- **Git**
- **Python**
- **Node.js**
- C/C++ tools: **CMake**, **GCC**

You could optionnally get a bunch of other applications:

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

## Setup

- The common setup is as easy as follow:

  ```bash
  # Clone the repository
  git clone https://github.com/nmarghetti/common_env.git

  # Run the setup
  bash ./common_env/scripts/setup.sh
  ```

- For a more advanced setup on Windows to get a more complete and portable development environment, follow this [guide](readme/README_setup.md).
