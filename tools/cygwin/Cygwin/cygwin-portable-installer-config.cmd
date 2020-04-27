@echo off

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://linux.rz.ruhr-uni-bochum.de/download/cygwin

:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set CYGWIN_ARCH=64

:: choose a user name under Cygwin
set CYGWIN_USERNAME=root

:: select the packages to be installed automatically via apt-cyg
set CYGWIN_PACKAGES=bash-completion,putty

:: if set to 'yes' the local package cache created by cygwin setup will be deleted after installation/update
set DELETE_CYGWIN_PACKAGE_CACHE=yes

:: if set to 'yes' the apt-cyg command line package manager (https://github.com/kou1okada/apt-cyg) will be installed automatically
set INSTALL_APT_CYG=yes

:: if set to 'yes' the bash-funk adaptive Bash prompt (https://github.com/vegardit/bash-funk) will be installed automatically
set INSTALL_BASH_FUNK=yes

:: if set to 'yes' Node.js (https://nodejs.org/) will be installed automatically
set INSTALL_NODEJS=no
:: Use of the folder names found here https://nodejs.org/dist/ as version name.
set NODEJS_VERSION=latest-v12.x
:: one of: auto,64,32 - specifies if 32 or 64 bit version should be installed or automatically detected based on current OS architecture
set NODEJS_ARCH=auto

:: if set to 'yes' Ansible (https://github.com/ansible/ansible) will be installed automatically
set INSTALL_ANSIBLE=no
set ANSIBLE_GIT_BRANCH=stable-2.9

:: if set to 'yes' AWS CLI (https://github.com/aws/aws-cli) will be installed automatically
set INSTALL_AWS_CLI=no

:: if set to 'yes' testssl.sh (https://testssl.sh/) will be installed automatically
set INSTALL_TESTSSL_SH=no
:: name of the GIT branch to install from, see https://github.com/drwetter/testssl.sh/
set TESTSSL_GIT_BRANCH=v2.9.5-8

:: use ConEmu based tabbed terminal instead of Mintty based single window terminal, see https://conemu.github.io/
set INSTALL_CONEMU=no
set CON_EMU_OPTIONS=-Title cygwin-portable ^
 -QuitOnClose

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%

:: set Mintty options, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
set MINTTY_OPTIONS=--Title cygwin-portable ^
  -o Columns=160 ^
  -o Rows=50 ^
  -o BellType=0 ^
  -o ClicksPlaceCursor=yes ^
  -o CursorBlinks=yes ^
  -o CursorColour=96,96,255 ^
  -o CursorType=Block ^
  -o CopyOnSelect=yes ^
  -o RightClickAction=Paste ^
  -o Font="Courier New" ^
  -o FontHeight=10 ^
  -o FontSmoothing=None ^
  -o ScrollbackLines=10000 ^
  -o Transparency=off ^
  -o Term=xterm-256color ^
  -o Charset=UTF-8 ^
  -o Locale=C
