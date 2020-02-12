# Install

## PortableApps ~13Mo

Create a folder and install it in there, eg. "D:/Apps". For now on, this folder will be referenced by **%APPS_ROOT%**.

Get PortableApps from [https://portableapps.com/](https://portableapps.com/).\
Click on "Start.exe" to start PortableApps platform.\
Install the portable apps you want, eg:

- Notepad++ ~8Mo
- Google Chrome ~250Mo
- Mozilla Firefox ~400Mo
- PuTTY ~4Mo
- 7-Zip ~8Mo
- Explorer++ ~5Mo
- jPortable (64-bit) ~180Mo
- Process Explorer ~4Mo
- YUMI-UEFI ~6Mo
- XAMPP launcher ~200Ko

## Git portable (tested with version 2.25.0) ~370Mo

- You can check some information about git on [https://git-scm.com](https://git-scm.com/).\
  Download the [64-bit Git for Windows Portable](https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/PortableGit-2.25.0-64-bit.7z.exe).\
  Create the folder "%APPS_ROOT%/PortableApps/PortableGit" and extract it there.
- Download wget utility from [https://eternallybored.org/misc/wget](https://eternallybored.org/misc/wget/) (tested with 64-bit version 1.20.3) and put wget.exe in "%APPS_ROOT%/PortableApps/PortableGit/mingw64/bin"
- Ensure to have this structure:

  ```text
  %APPS_ROOT%
  |- Documents
  |- PortableApps
  |  `- PortableGit
  |     |- mingw64
  |     |  `- bin
  |     |     `- wget.exe
  |     `- git-bash.exe
  `- Start.exe
  ```

- Run "%APPS_ROOT%/PortableApps/PortableGit/git-bash.exe"\
  Type the following:

  ```bash
  # Assuming that %APPS_ROOT% is "D:/Apps"
  export APPS_ROOT="/d/Apps"
  export HOME="${APPS_ROOT}/home"

  mkdir -p ${APPS_ROOT}/Documents/dev
  # If you want to contribute, fork it and clone your own fork
  git clone https://github.com/nmarghetti/common_env.git "${APPS_ROOT}/Documents/dev/common_env"

  # Select the applications you want to install as parameter (vscode, node, cpp, xampp or all if you want them all)
  "${APPS_ROOT}/Documents/dev/common_env/scripts/setup.sh" all
  ```

  It will install and configure the following tools:

  - Visual Studio Code [portable](https://code.visualstudio.com/docs/editor/portable) 64 bit version [1.41.1](https://code.visualstudio.com/download) ~850Mo
  - Python 64 bit version [3.8.1](https://www.python.org/downloads/release/python-381/) ~50Mo
  - NodeJs version [v12.14.1](https://nodejs.org/dist/v12.14.1/) and the latest version of yarn ~60Mo
  - CMake 64 bit version [3.16.3](https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-win64-x64.zip) ~80Mo
  - GCC [9.2](https://gcc.gnu.org/onlinedocs/) build with a [release](http://repo.msys2.org/distrib/x86_64/) of [msys2](https://www.msys2.org/) ~1.5Go
  - XAMPP [7.4.2](https://www.apachefriends.org/download.html) (XAMPP Launcher portable app required) ~600Mo

- You can create shortcuts for
  - "%APPS_ROOT%/home/bash.cmd": run git bash through windows cmd
  - "%APPS_ROOT%/home/mintty.cmd": run git bash through mintty

**!!! IMPORTANT !!!**\
Close the terminal opened and the PortableApps. As the PATH has been updated, those application needs to be restarted to take it into account.
