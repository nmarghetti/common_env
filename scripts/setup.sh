#! /bin/bash

# Crazy stuff to check about bash there:
# https://github.com/niieani/bash-oo-framework
# https://github.com/reduardo7/bashx
# https://github.com/mnorin/bash-scripts
# https://github.com/mnorin/bash-scripts/tree/master/objects

# Check it is ran with bash
if [ ! "$(basename "$SHELL")" = "bash" ]; then
  echo "Please run with: bash $0" >&2
  exit 1
fi

export COMMON_ENV_DEBUG_CMD="[ \"\$COMMON_ENV_FULL_DEBUG\" = \"1\" ] && { system_trace_debug() { echo \"DEBUG: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; system_trace_error() { echo \"ERROR: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; trap 'system_trace_debug \"\$?\" \"\$BASH_COMMAND\" ' DEBUG;  trap 'system_trace_error \"\$?\" \"\$BASH_COMMAND\" ' ERR; }"
[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"

# Check 'readlink -f' is available
readlink -f "$0" &>/dev/null
if [ $? -ne 0 ]; then
  [ ! "$(uname -s)" = "Darwin" ] && echo "Unable to use 'readlink -f', exiting." && exit 1
  echo "Setup for MAC"
  # Try to run the Mac setup if readlink -f is not available
  source "$(dirname "$0")/../tools/mac/setup_mac.sh"
  [ $? -ne 0 ] && echo "Unable to run setup for mac" && exit 1
  readlink -f "$0" &>/dev/null
  [ $? -ne 0 ] && echo "Unable to use 'readlink -f', exiting." && exit 1
fi

SCRIPT_NAME=$(basename "$0")
SETUP_SCRIPT_ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
SETUP_SCRIPT_PATH="$SETUP_SCRIPT_ROOT/$SCRIPT_NAME"
SETUP_ROOT="$(dirname "$SETUP_SCRIPT_ROOT")"
SETUP_TOOLS_ROOT="$SETUP_ROOT/tools"

cd "$SETUP_ROOT"
[ $? -ne 0 ] && echo "Unable to go to the parent directory of $SCRIPT_NAME ($SETUP_ROOT)" && exit 1

SETUP_SILENT=0
DEFAULT_APPS="bash git"
APPS=$DEFAULT_APPS

usage() {
  echo "Usage: $SCRIPT_NAME [-s|--silent] [app [app...] | all]" 1>&2
  echo "  Options:" 1>&2
  echo "    -s,--silent: do not ask for answer, automatically take the affirmative" 1>&2
  echo "  Possible apps:" 1>&2
  echo "    python2: install python 2.7.17 and sets a virtual env" 1>&2
  echo "    vscode: install Visual Studio Code 1.44.0" 1>&2
  echo "    cmder: install cmder 1.3.14" 1>&2
  echo "    node: install NodeJs 2.14.1" 1>&2
  echo "    cpp: install make, cmake and GNU C++ compiler" 1>&2
  echo "    xampp: install apache" 1>&2
  echo "In any case it will setup some bash and git config, and (only on Windows) install python 3.8.2" 1>&2
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
  python2)
    APPS="$APPS python2"
    ;;
  vscode)
    APPS="$APPS vscode"
    ;;
  cmder)
    APPS="$APPS cmder"
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
  -s | --silent)
    SETUP_SILENT=1
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

# If no apps given, take the ones from config file
if [ "$APPS" = "$DEFAULT_APPS" ]; then
  common_env_app=$(git config -f "$HOME/.common_env.ini" --get-all install.app | grep -vE '^(bash|git|gitbash|portableapps|python)$' | tr '\n' ' ')
  [ -n "$common_env_app" ] && APPS="$APPS $common_env_app"
fi

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

# Check there is no space character in the paths used, otherwise warn the user
path_with_space=
for path in SETUP_SCRIPT_PATH HOME APPS_ROOT; do
  if [ "$(echo "${!path}" | grep -c '[[:space:]]')" -ne 0 ]; then
    path_with_space="$path_with_space $path"
  fi
done
if [ -n "$path_with_space" ]; then
  echo "!!! Warning !!! Even though it should be working, it might cause problem to have space in some path:"
  for path in $path_with_space; do
    echo "    $path: '${!path}'"
  done
  answer='y'
  if [ $SETUP_SILENT -eq 0 ]; then
    answer='n'
    echo "Are you sure you want to proceed ? (y/N) "
    read -r answer
  fi
  [[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1
fi

# check $HOME
check_dir_var HOME || exit $?
# check $APPS_ROOT
check_dir_var APPS_ROOT &>/dev/null
if [ $? -ne 0 ]; then
  unset APPS_ROOT
  if [ ! "$APPS" = "$DEFAULT_APPS" ]; then
    APPS=$DEFAULT_APPS
    check_dir_var APPS_ROOT Info
    echo "Only apps that dont need \$APPS_ROOT will be installed: $APPS" >&2
  fi
fi

# get functions to check the system
source "$SETUP_TOOLS_ROOT/bash/source/system.sh"

if [ -n "$APPS_ROOT" ]; then
  source "$SETUP_TOOLS_ROOT/bash/source/path_windows.sh"

  # Ensure to get APPS_ROOT as posix path if not
  if [ "$(echo "$APPS_ROOT" | grep -c ':')" -ne 0 ]; then
    APPS_ROOT="$(get_path_to_posix "$APPS_ROOT")"
    [ $? -ne 0 ] || [ ! -d "$APPS_ROOT" ] && echo "APPS_ROOT='$APPS_ROOT' does not exist" && exit 1
  fi

  export WIN_APPS_ROOT="$(get_path_to_windows "$APPS_ROOT")"
  export WINDOWS_APPS_ROOT="$(get_path_to_windows_back "$APPS_ROOT")"
  export APPS_COMMON="$APPS_ROOT/PortableApps/CommonFiles"
  export WIN_APPS_COMMON="$(get_path_to_windows "$APPS_COMMON")"

  # Ensure that git will be in the path is not yet the case
  type git &>/dev/null || export PATH=$APPS_ROOT/PortableApps/PortableGit/bin:$PATH

  # Ensure to also setup gitbash, portableapps and python
  APPS="gitbash portableapps python $APPS"
fi

# Install the selected apps
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

[ -f "$HOME/.common_env_check" ] && rm -f "$HOME/.common_env_check"
echo -e "Setup done.\n"
shellrc=.bashrc
[ "$(basename "$(system_get_default_shell)")" = "zsh" ] && shellrc=.zshrc
echoColor 33 "Please run the following command to complete:"
echo "source '$HOME/$shellrc'"
echo
