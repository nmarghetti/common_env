# Install

## PortableApps

Create a folder and install it in there, eg. "D:/PortableApps". For now on, this folder will be referenced by **%APPS_ROOT%**.

Get PortableApps from [https://portableapps.com/](https://portableapps.com/).\
Click on "Start.exe" to start PortableApps platform.\
Install the portable apps you want, eg:

- Notepad++
- Google Chrome
- Mozilla Firefox
- PuTTY
- 7-Zip
- Explorer++
- jPortable (64-bit)
- Process Explorer
- YUMI-UEFI

## Git portable (tested with version 2.25.0)

Download the "64-bit Git for Windows Portable" from [https://git-scm.com/](https://git-scm.com/).\
Create the folder "%APPS_ROOT%/PortableApps/PortableGit" and install it there.\
Download wget utility for git from [https://eternallybored.org/misc/wget/](https://eternallybored.org/misc/wget/) (tested with 64-bit version 1.20.3) and put it "%APPS_ROOT%/PortableApps/PortableGit/mingw64/bin"\
Run "%APPS_ROOT%/PortableApps/PortableGit/git-bash.exe"\
Type the following:

```bash
# Assuming that %APPS_ROOT% is "D:/PortableApps"
export APPS_ROOT="/d/PortableApps"
export HOME="${APPS_ROOT}/home"

mkdir -p ${APPS_ROOT}/Documents/dev
# If you want to contribute, fork it and clone your own fork
git clone https://github.com/nmarghetti/common_env.git "${APPS_ROOT}/Documents/dev/common_env"
"${APPS_ROOT}/Documents/dev/common_env/scripts/setup.sh"
```

It will install and configure the following tools:

- Visual Studio Code [portable](https://code.visualstudio.com/docs/editor/portable) version [1.41.1](https://code.visualstudio.com/download) (64 bit).
- Python 64 bit version [3.8.1](https://www.python.org/downloads/release/python-381/)

**!!! IMPORTANT !!!**\
Close the terminal opened and the PortableApps. As the PATH has been updated, those application needs to be restarted to take it into account.
