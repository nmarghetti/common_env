#! /usr/bin/env bash

# Crazy stuff to check about bash there:
# https://github.com/niieani/bash-oo-framework
# https://github.com/reduardo7/bashx
# https://github.com/mnorin/bash-scripts
# https://github.com/mnorin/bash-scripts/tree/master/objects

# Check it is ran with bash
if [[ ! "$(basename "$SHELL" .exe)" = "bash" ]]; then
  echo "Please run with: bash $0" >&2
  exit 1
fi

[[ "$(echo "$BASH_VERSION" | cut -b 1)" -lt 4 ]] && echo "Please use bash 4 or above" && exit 1

export COMMON_ENV_DEBUG_CMD="[ \"\$COMMON_ENV_FULL_DEBUG\" = \"1\" ] && { system_trace_debug() { echo \"DEBUG: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; system_trace_error() { echo \"ERROR: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; trap 'system_trace_debug \"\$?\" \"\$BASH_COMMAND\" ' DEBUG;  trap 'system_trace_error \"\$?\" \"\$BASH_COMMAND\" ' ERR; }"
[[ "$COMMON_ENV_FULL_DEBUG" == "1" ]] && eval "$COMMON_ENV_DEBUG_CMD"

# Check 'readlink -f' is available
readlink -f "$0" &>/dev/null
if [[ $? -ne 0 ]]; then
  [[ ! "$(uname -s)" = "Darwin" ]] && echo "Unable to use 'readlink -f', exiting." && exit 1
  echo "Setup for MAC"
  # Try to run the Mac setup if readlink -f is not available
  source "$(dirname "$0")/../tools/mac/setup_mac.sh"
  [[ $? -ne 0 ]] && echo "Unable to run setup for mac" && exit 1
  readlink -f "$0" &>/dev/null
  [[ $? -ne 0 ]] && echo "Unable to use 'readlink -f', exiting." && exit 1
fi

SCRIPT=${BASH_SOURCE[0]}
if [[ -z "$SCRIPT" ]] || [[ "$SCRIPT" = "bash" ]]; then
  SCRIPT=$0
fi
SCRIPT_NAME=$(basename "$SCRIPT")
SETUP_SCRIPT_ROOT=$(cd "$(dirname "$(readlink -f "$SCRIPT")")" && pwd)
SETUP_SCRIPT_PATH="$SETUP_SCRIPT_ROOT/$SCRIPT_NAME"
SETUP_ROOT="$(dirname "$SETUP_SCRIPT_ROOT")"
SETUP_TOOLS_ROOT="$SETUP_ROOT/tools"

# Tweak debug mode
[[ "$(basename "$0")" == "bashdb" ]] && {
  export APPS_ROOT=$(readlink -f "$(dirname "$SETUP_ROOT")/../..")
  export HOME=$APPS_ROOT/home
}

cd "$SETUP_ROOT"
[[ $? -ne 0 ]] && echo "Unable to go to the parent directory of $SCRIPT_NAME ($SETUP_ROOT)" && exit 1

SETUP_SILENT=0
SETUP_SKIP_DEFAULT=0
DEFAULT_APPS="bash git"
# Remove pacman form default so far as it seems to break bash
# DEFAULT_WIN_APPS="$DEFAULT_APPS gitbash pacman portableapps python"
DEFAULT_WIN_APPS="$DEFAULT_APPS gitbash portableapps python"
DEFAULT_APPS_GREP=$(echo "$DEFAULT_WIN_APPS" | tr ' ' '|')
APPS=

usage() {
  echo "Usage: $SCRIPT_NAME [-s|--silent] [app [app...]]" 1>&2
  echo "  Options:" 1>&2
  echo "    -s,--silent: do not ask for answer, automatically take the affirmative" 1>&2
  echo "  Possible apps:" 1>&2
  echo "    python2: install python 2.7.17 and sets a virtual env" 1>&2
  echo "    vscode: install latest Visual Studio Code" 1>&2
  echo "    pycharm: install latest PyCharm community" 1>&2
  echo "    cmder: install cmder 1.3.14" 1>&2
  echo "    mobaxterm: install MobaXterm 20.2" 1>&2
  echo "    putty: install PuTTY 0.73" 1>&2
  echo "    superputty: install SuperPuTTY 1.4.0.9" 1>&2
  echo "    autohotkey: install AutoHotkey >=1.1.32" 1>&2
  echo "    node: install NodeJs 12.19.0" 1>&2
  echo "    gradle: install Gradle 6.7.1" 1>&2
  echo "    cygwin: install Cygwin" 1>&2
  # echo "    cpp: install make, cmake and GNU C++ compiler" 1>&2
  echo "    xampp: install apache" 1>&2
  echo "In any case it will setup some bash and git config, and (only on Windows) install python 3.8.2" 1>&2
}

check_dir_var() {
  var=$1
  msg="Error"
  if [[ ! -z "$2" ]]; then
    msg=$2
  fi
  test -z "${!var}" && echo "$msg: $var is not set !!!" >&2 && return 1
  test ! -d "${!var}" && echo "$msg with $var: '${!var}' does not exist !!!" >&2 && return 1
  return 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
  bash | git | gitbash | pacman | portableapps | python)
    APPS="$APPS $1"
    ;;
  pacman | python2 | vscode | pycharm | cmder | mobaxterm | putty | superputty | autohotkey | cygwin | node | gradle | xampp)
    APPS="$APPS $1"
    ;;
  # cpp)
  #   APPS="$APPS make cmake msys2"
  #   ;;
  -s | --silent)
    SETUP_SILENT=1
    ;;
  -k | --skip-default-apps)
    SETUP_SKIP_DEFAULT=1
    ;;
  -h | --help)
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

if [[ -f "$HOME/.common_env.ini" ]]; then
  # If no apps given, take the ones from config file
  if [[ -z "$APPS" ]]; then
    common_env_app=$(git config -f "$HOME/.common_env.ini" --get-all install.app | grep -vE "^($DEFAULT_APPS_GREP)$" | tr '\n' ' ')
    [[ -n "$common_env_app" ]] && APPS="$DEFAULT_APPS $common_env_app"
  fi
  [[ "$(git config -f $HOME/.common_env.ini --get install.sslcheck)" == "0" ]] && export DOWNLOAD_NO_SSL_CHECK=1
fi

# Ensure to have default apps (except if skipped)
[[ "$SETUP_SKIP_DEFAULT" -eq 0 ]] && APPS="$DEFAULT_APPS $(echo "$APPS" | tr ' ' '\n' | grep -vE "^($DEFAULT_APPS_GREP)$" | tr '\n' ' ')"

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
check_dir_var APPS_ROOT &>/dev/null
if [[ $? -ne 0 ]]; then
  unset APPS_ROOT
  if [[ ! "$APPS" == "$DEFAULT_APPS" ]]; then
    APPS=$DEFAULT_APPS
    check_dir_var APPS_ROOT Info
    echo "Only apps that dont need \$APPS_ROOT will be installed: $APPS" >&2
  fi
fi

# get functions to check the system
source "$SETUP_TOOLS_ROOT/bash/source/system.sh"

if [[ -n "$APPS_ROOT" ]]; then
  source "$SETUP_TOOLS_ROOT/bash/source/path_windows.sh"

  # Ensure to get APPS_ROOT as posix path if not
  if [[ "$(echo "$APPS_ROOT" | grep -c ':')" -ne 0 ]]; then
    APPS_ROOT="$(get_path_to_posix "$APPS_ROOT")"
    [[ $? -ne 0 ]] || [[ ! -d "$APPS_ROOT" ]] && echo "APPS_ROOT='$APPS_ROOT' does not exist" && exit 1
  fi

  export APPDATA="$APPS_ROOT/AppData/Roaming"
  export LOCALAPPDATA="$APPS_ROOT/AppData/Local"
  export WIN_APPS_ROOT="$(get_path_to_windows "$APPS_ROOT")"
  export WINDOWS_APPS_ROOT="$(get_path_to_windows_back "$APPS_ROOT")"
  export WINDOWS_SETUP_TOOLS_ROOT="$(get_path_to_windows_back "$SETUP_TOOLS_ROOT")"
  export APPS_COMMON="$APPS_ROOT/PortableApps/CommonFiles"
  export WIN_APPS_COMMON="$(get_path_to_windows "$APPS_COMMON")"

  mkdir -p "$APPDATA" "$LOCALAPPDATA"

  # Ensure that git will be in the path if not yet the case
  type git &>/dev/null || export PATH=$APPS_ROOT/PortableApps/PortableGit/bin:$PATH

  # Ensure to have default windows apps (except if skipped)
  [[ "$SETUP_SKIP_DEFAULT" -eq 0 ]] && APPS="$DEFAULT_WIN_APPS $(echo "$APPS" | tr ' ' '\n' | grep -vE "^($DEFAULT_APPS_GREP)$" | tr '\n' ' ')"
fi

# Check there is no space character in the paths used, otherwise warn the user
path_with_space=
for path in SETUP_SCRIPT_PATH HOME APPS_ROOT; do
  if [[ "$(echo "${!path}" | grep -c '[[:space:]]')" -ne 0 ]]; then
    path_with_space="$path_with_space $path"
  fi
done
if [[ -n "$path_with_space" ]]; then
  echo "!!! Warning !!! Even though it should be working, it might cause problem to have space in some path:"
  for path in $path_with_space; do
    echo "    $path: '${!path}'"
  done
  answer='y'
  if [[ $SETUP_SILENT -eq 0 ]] && !([[ -n "$APPS_ROOT" ]] && [[ -f "$APPS_ROOT/home/.gitconfig" ]]); then
    answer='n'
    read -rep "Are you sure you want to proceed (y/N) ? " -i $answer answer
  fi
  [[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1
fi

# Get functions to download tarball
source "$SETUP_TOOLS_ROOT/$tool/bash/bin/download_tarball.sh"

# Install the selected apps
for tool in $APPS; do
  if [[ -f "$SETUP_TOOLS_ROOT/$tool/setup.sh" ]]; then
    echoSection $tool
    source "$SETUP_TOOLS_ROOT/$tool/setup.sh"
    "setup_$tool"
    ret=$?
    if [[ $ret -eq 0 ]]; then
      echoSectionDone $tool
    else
      echoSectionError "$tool (code $ret)"
      case $ret in
      $SETUP_ERROR_CONTINUE) ;;

      *)
        exit $ret
        ;;
      esac
    fi
  fi
done

# Update the apps installed in $HOME/.common_env.ini
common_env_app="$(git config -f "$HOME/.common_env.ini" --get-all install.app | tr '\n' ' ') $APPS"
common_env_app="$(echo "$common_env_app" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"
git config -f "$HOME/.common_env.ini" --unset-all install.app
for app in $common_env_app; do
  git config -f "$HOME/.common_env.ini" --add install.app $app
done

[[ -f "$HOME/.common_env_check" ]] && rm -f "$HOME/.common_env_check"
echo -e "Setup done.\n"
shellrc=.bashrc
[[ "$(basename "$(system_get_default_shell)")" = "zsh" ]] && shellrc=.zshrc
echoColor 33 "Please run the following command to complete:"
echo "source '$HOME/$shellrc'"
echo
