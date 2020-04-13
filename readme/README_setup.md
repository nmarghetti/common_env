# Install

## Automatic setup

1. **Download**

   - **Create** a folder where you want to install it, eg. "**D:/Apps**".
   - **Download** this [**setup.cmd**](https://raw.githubusercontent.com/nmarghetti/common_env/master/tools/setup.cmd) inside (Right click -> "Save Link As...", save into "D:/Apps/setup.cmd").
   - Optionnally download this [setup.ini](https://raw.githubusercontent.com/nmarghetti/common_env/master/tools/setup.ini) inside also (Right click -> "Save Link As...", save into "D:/Apps/setup.ini"). You can edit it to set the list of apps you want.
   - **Execute setup.cmd** and follow the instructions.

   It will try to download [PortableApps 16.1.1](https://portableapps.com/downloading/?a=PortableApps.comPlatform&s=s&d=pa&n=The%20PortableApps.com%20Platform&f=PortableApps.com_Platform_Setup_16.1.1.paf.exe) and [64-bit Git for Windows Portable 2.2.26](https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/PortableGit-2.26.0-64-bit.7z.exe), with curl or wget.\
   You can manually download the versions you want as far as you named the files as follow:

   - D:/Apps/PortableApps.exe
   - D:/Apps/PortableGit.exe

   If you dont have wget or curl on your machine, you can download the 2 above manually, or download [64-bit wget 1.20.3](https://eternallybored.org/misc/wget/1.20.3/64/wget.exe) as follow:

   - D:/Apps/wget.exe

   Basically, this would ensure to have a good setup:

   ```text
    D:/Apps
    ├── PortableApps.exe
    ├── PortableGit.exe
    ├── setup.cmd
    └── setup.ini
   ```

1. **Installation**

   1. PortableApps
      - Press OK for language selection (you can change it later)
      - Press Next and Agree
      - Select radio button "Select a custom location..." and press Next
      - Do not change "Destination Folder" and press Next and Install
      - **_!!! Untick "Run PortableApps Platform" and press Finish !!!_**
   1. Git for Windows
      - Do not change the destination and press OK
   1. Git config
      - Enter your user name and email address

   You should end up with a folder structure as follow:

   ```text
   D:/Apps
   ├── Documents
   ├── PortableApps
   ├── Start.exe
   └── home
   ```

   You can launch Start.exe to start PortableApps. From there you will be able to run Git bash terminal, the user's HOME would be the home folder above.

## Git portable (version 2.26.0) ~370Mo

You can now run Git bash through the PortableApps to get more custom apps.\
Launch "Git bash terminal" and type the following:

```bash
# Select the applications you want to install as parameter (python2, python, vscode, node, cpp, xampp or all if you want them all)
# It will anyway configure your .bashrc and .gitconfig
setup_common_env python vscode
```

It can install and configure the following tools:

- Visual Studio Code [portable](https://code.visualstudio.com/docs/editor/portable) 64-bit version [1.44.0](https://code.visualstudio.com/download) ~300Mo
  - Several extensions ~400Mo
- Python version [2.7.17](https://www.python.org/downloads/release/python-2717/) ~90Mo
- Python 64-bit version [3.8.2](https://www.python.org/downloads/release/python-382/) ~50Mo
- NodeJs version [v12.14.1](https://nodejs.org/dist/v12.14.1/) and the latest version of yarn ~60Mo
- CMake 64-bit version [3.16.3](https://github.com/Kitware/CMake/releases/download/v3.16.3/cmake-3.16.3-win64-x64.zip) ~80Mo
- GCC [9.2](https://gcc.gnu.org/onlinedocs/) build with a [release](http://repo.msys2.org/distrib/x86_64/) of [msys2](https://www.msys2.org/) ~1.5Go
- XAMPP [7.4.2](https://www.apachefriends.org/download.html) (XAMPP Launcher portable app required) ~600Mo

## PortableApps Applications

Launch "D:/Apps/Start.exe" to start PortableApps platform.\
On the right side click on the button Apps -> Get More Apps... -> By Category\
You can then select many portable applications you want to have, eg:

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
