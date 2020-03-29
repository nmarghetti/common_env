#! /bin/bash

# Check it is ran with bash
if [ ! "$(basename "$SHELL")" = "bash" ]; then
  echo "Please run with: bash $0" >&2
  exit 1
fi

# Check 'readlink -f' is available
readlink -f "$0" &>/dev/null
if [ $? -ne 0 ]; then
  [ ! "$(uname -s )" = "Darwin" ] && echo "Unable to use 'readlink -f', exiting." && exit 1
  echo "Setup for MAC"
  # Try to run the Mac setup if readlink -f is not available
  source "$(dirname "$0")/../tools/mac/setup_mac.sh"
  [ $? -ne 0 ] && echo "Unable to run setup for mac" && exit 1
  readlink -f "$0" &>/dev/null
  [ $? -ne 0 ] && echo "Unable to use 'readlink -f', exiting." && exit 1
fi

SCRIPT_NAME=$(basename "$0")
SETUP_SCRIPT_ROOT=$(dirname "$(readlink -f "$0")")
SETUP_TOOLS_ROOT=$(readlink -f "$SETUP_SCRIPT_ROOT/../tools")

DEFAULT_APPS="bash git"
APPS=$DEFAULT_APPS

usage() {
  echo "Usage: $SCRIPT_NAME [-s|--silent] [app [app...] | all]" 1>&2
  echo "  Options:" 1>&2
  echo "    -s,--silent: do not ask for answer, automatically take the affirmative" 1>&2
  echo "  Possible apps:" 1>&2
  echo "    vscode: install Visual Studio Code" 1>&2
  echo "    node: install NodeJs" 1>&2
  echo "    cpp: install make, cmake and GNU C++ compiler" 1>&2
  echo "    xampp: install apache" 1>&2
  echo "    all: install all the apps above" 1>&2
  echo "In any case it will setup some bash and git config and python" 1>&2
}

check_dir_var() {
  var=$1
  msg="Error"
  if [ ! -z "$2" ]; then
    msg=$2
  fi
  test -z "${!var}" && echo "$msg: $var is not set !!!" >&2 && return 1
  test ! -d "${!var}" && echo "$msg with $var: '${!var}' does not exist !!!" >&2 && return 1
  return 0
}

while [ $# -gt 0 ]; do
  case $1 in
    python)
      APPS="$APPS python"
    ;;
    vscode)
      APPS="$APPS vscode windows_path"
    ;;
    cpp)
      APPS="$APPS make cmake msys2"
    ;;
    node)
      APPS="$APPS node"
    ;;
    xampp)
      APPS="$APPS xampp"
    ;;
    all)
      APPS="bash git python vscode windows_path node make cmake msys2 xampp"
    ;;
    -s|--silent)
      SETUP_SILENT=1
    ;;
    -h|--help)
      usage
      exit 0
    ;;
    *)
      usage
      exit 1
    ;;
  esac
  shift
done

SETUP_ERROR_CONTINUE=100
SETUP_ERROR_STOP=101

function echoColor() {
  color=$1
  shift
  echo -e "\033[${color}m$@\033[0m"
}

function echoSection() {
  echoColor 33 "Setup for $@..."
}

function echoSectionDone() {
  echoColor 33 "Setup for $@ done.\n"
}

function echoSectionError() {
  echoColor 31 "Setup for $@ failed !!!\n"
}

# check $HOME
check_dir_var HOME || exit $?
# check $APPS_ROOT
check_dir_var APPS_ROOT Info
if [ $? -ne 0 ]; then
  unset APPS_ROOT
  APPS=$DEFAULT_APPS
  echo "Only apps that dont need \$APPS_ROOT will be installed: $APPS" >&2
else
  export WIN_APPS_ROOT="$(echo "$APPS_ROOT" | cut -b 2 | tr '[:lower:]' '[:upper:]'):$(echo "$APPS_ROOT" | cut -b 3-)"
  export WINDOWS_APPS_ROOT="$(echo "$WIN_APPS_ROOT" | tr '/' '\\')"
  # check wget is installed
  if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/wget.exe" ]; then
    if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/mingw64/bin/wget.exe" ]; then
      APPS=$DEFAULT_APPS
      echo "Please read the README, download wget and put it there: $APPS_ROOT/PortableApps/PortableGit/mingw64/bin/wget.exe" >&2
      echo "Only apps that dont need wget will be installed: $APPS" >&2
    else
      cp -vf "$APPS_ROOT/PortableApps/PortableGit/mingw64/bin/wget.exe" "$APPS_ROOT/PortableApps/PortableGit/usr/bin/"
    fi
  fi
fi


for tool in $APPS; do
  if [ -f "$SETUP_TOOLS_ROOT/$tool/setup.sh" ]; then
    echoSection $tool
    source "$SETUP_TOOLS_ROOT/$tool/setup.sh"
    "setup_$tool"
    ret=$?
    if [ $ret -eq 0 ]; then
      echoSectionDone $tool
    else
      echoSectionError "$tool (code $ret)"
      case $ret in
        $SETUP_ERROR_CONTINUE)
        ;;
        *)
          exit $ret
      esac
    fi
  fi
done

echo "Setup done"
