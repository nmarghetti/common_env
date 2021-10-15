#! /usr/bin/env bash

# shellcheck disable=SC2009
# SC2009: Consider using pgrep instead of grepping ps output.

# Crazy stuff to check about bash there:
# https://github.com/niieani/bash-oo-framework
# https://github.com/reduardo7/bashx
# https://github.com/mnorin/bash-scripts
# https://github.com/mnorin/bash-scripts/tree/master/objects

exit_error() {
  echo "$*" >&2
  exit 1
}

# Check it is ran with bash
ps -p $$ | grep -qc bash || exit_error "Please run with: bash $0"

[[ "$(echo "$BASH_VERSION" | cut -b 1)" -lt 4 ]] && exit_error "Please use bash 4 or above"

export COMMON_ENV_DEBUG_CMD="[ \"\$COMMON_ENV_FULL_DEBUG\" = \"1\" ] && { system_trace_debug() { echo \"DEBUG: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; system_trace_error() { echo \"ERROR: \$2 --> \$1 [\${BASH_SOURCE[0]}:\${BASH_LINENO[0]}]\"; }; trap 'system_trace_debug \"\$?\" \"\$BASH_COMMAND\" ' DEBUG;  trap 'system_trace_error \"\$?\" \"\$BASH_COMMAND\" ' ERR; }"
[[ "$COMMON_ENV_FULL_DEBUG" == "1" ]] && eval "$COMMON_ENV_DEBUG_CMD"

if [[ "$(uname -s)" = "Darwin" ]]; then
  echo "Setup for MAC"
  # shellcheck source=../tools/mac/setup_mac.sh
  source "$(dirname "$0")/../tools/mac/setup_mac.sh"
fi

# Check 'readlink -f' is available
readlink -f "$0" &>/dev/null || exit_error "Unable to use 'readlink -f', exiting."

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
  APPS_ROOT=$(readlink -f "$(dirname "$SETUP_ROOT")/../..")
  export APPS_ROOT
  export HOME=$APPS_ROOT/home
}

cd "$SETUP_ROOT" || exit_error "Unable to go to the parent directory of $SCRIPT_NAME ($SETUP_ROOT)"

SETUP_SILENT=0
SETUP_SKIP_DEFAULT=0
DEFAULT_APPS="shell git"
DEFAULT_WIN_APPS="gitbash $DEFAULT_APPS portableapps"
DEFAULT_APPS_GREP=$(echo "$DEFAULT_WIN_APPS" | tr ' ' '|')
APPS=
UPGRADE_APPS=0
APP_SELECTED=0
EXTRA_APP_SELECTED=0
EXTRA_APPS=

usage() {
  echo "Usage: $SCRIPT_NAME [-s|--silent] [-u|--upgrade] [app [app...]] [-e app[,app...]]" 1>&2
  echo "  Options:" 1>&2
  echo "    -s,--silent: do not ask for answer, automatically take the affirmative" 1>&2
  echo "    -u,--upgrade: when possible, it will upgrade the apps" 1>&2
  echo "    -e,--extra-apps: install only given extra app" 1>&2
  echo "  Possible apps:" 1>&2
  echo "    python2: install python 2.7.17 and sets a virtual env" 1>&2
  echo "    java: install java jdk 8, 11 or 16 (16 by default)" 1>&2
  echo "    vscode: install latest Visual Studio Code" 1>&2
  echo "    pycharm: install latest PyCharm community" 1>&2
  echo "    intellijidea: install latest IntelliJ IDEA community" 1>&2
  echo "    cmder: install cmder 1.3.14" 1>&2
  echo "    mobaxterm: install MobaXterm 20.6" 1>&2
  echo "    putty: install PuTTY 0.73" 1>&2
  echo "    superputty: install SuperPuTTY 1.4.0.9" 1>&2
  echo "    tabby: install Tabby" 1>&2
  echo "    autohotkey: install AutoHotkey >=1.1.32" 1>&2
  echo "    node: install NodeJs 12.20.0" 1>&2
  echo "    nvm: install nvm which is a nodejs version manager" 1>&2
  echo "    insomnia: install Insomnia REST client 2021.5.0" 1>&2
  echo "    gradle: install Gradle 6.7.1" 1>&2
  echo "    cygwin: install Cygwin" 1>&2
  echo "    elastic: install Elasticsearch, Logstash and Kibana (you would need to install java also)" 1>&2
  echo "    gcloud: install google cloug sdk" 1>&2
  echo "    lens: install Kubernetes IDE" 1>&2
  # echo "    cpp: install make, cmake and GNU C++ compiler" 1>&2
  echo "    xampp: install apache" 1>&2
  echo "    wsl: configure WSL" 1>&2
  echo "In any case it will setup some shell and git config, and (only on Windows) install python 3.8.2" 1>&2
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
    shell | git | gitbash | pacman | portableapps | python | \
      java | python2 | vscode | pycharm | cmder | mobaxterm | putty | superputty | tabby | autohotkey | \
      cygwin | node | nvm | insomnia | gradle | xampp | elastic | wsl | intellijidea | gcloud | lens)
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
      APP_SELECTED=1
      ;;
    -e | --extra-apps)
      SETUP_SKIP_DEFAULT=1
      EXTRA_APP_SELECTED=1
      shift
      EXTRA_APPS="$(echo "$1" | tr ',' ' ')"
      ;;
    -u | --update)
      UPGRADE_APPS=1
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
  # Ensure it is unix compliant
  cat -v "$HOME/.common_env.ini" | grep '\^M' >/dev/null && dos2unix "$HOME/.common_env.ini"
  # If no apps given, take the ones from config file
  if [[ -z "$APPS" ]]; then
    common_env_app=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all install.app | grep -vE "^($DEFAULT_APPS_GREP)$" | tr '\n' ' ')
    [[ -n "$common_env_app" ]] && APPS="$DEFAULT_APPS $common_env_app"
  fi
  if [[ "$(git --no-pager config -f "$HOME/.common_env.ini" --get install.sslcheck 2>/dev/null)" == "0" ]]; then
    export DOWNLOAD_NO_SSL_CHECK=1
    "$SETUP_TOOLS_ROOT/ssl_allow.sh"
  fi
fi

# Ensure to have default apps (except if skipped)
[[ "$SETUP_SKIP_DEFAULT" -eq 0 ]] && APPS="$DEFAULT_APPS $(echo "$APPS" | tr ' ' '\n' | grep -vE "^($DEFAULT_APPS_GREP)$" | tr '\n' ' ')"

export SETUP_ERROR_CONTINUE=100
export SETUP_ERROR_STOP=101

function echoColor() {
  color=$1
  shift
  echo -e "\033[${color}m$*\033[0m"
}

function echoSection() {
  echoColor 33 "Setup for $*..."
}

function echoSectionDone() {
  echoColor 33 "Setup for $* done.\n"
}

function echoSectionError() {
  echoColor 31 "Setup for $* failed !!!\n"
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
# shellcheck source=../tools/shell/source/system.sh
source "$SETUP_TOOLS_ROOT/shell/source/system.sh"

if [[ -n "$APPS_ROOT" ]]; then
  # shellcheck source=../tools/shell/source/path_windows.sh
  source "$SETUP_TOOLS_ROOT/shell/source/path_windows.sh"

  # Ensure to get APPS_ROOT as posix path if not
  if [[ "$(echo "$APPS_ROOT" | grep -c ':')" -ne 0 ]]; then
    APPS_ROOT="$(get_path_to_posix "$APPS_ROOT")"
    [[ ! -d "$APPS_ROOT" ]] && exit_error "APPS_ROOT='$APPS_ROOT' does not exist"
  fi

  # https://www.joshkel.com/2018/01/18/symlinks-in-windows/
  # Ensure to have proper symlinks
  echo "$MSYS" | grep -q 'winsymlinks:nativestrict' || export MSYS="$MSYS winsymlinks:nativestrict"

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
  if [[ $SETUP_SILENT -eq 0 ]] && ! { [[ -n "$APPS_ROOT" ]] && [[ -f "$APPS_ROOT/home/.gitconfig" ]]; }; then
    answer='n'
    read -rep "Are you sure you want to proceed (y/N) ? " -i $answer answer
  fi
  [[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1
fi

# Get functions to download tarball
# shellcheck source=../tools/shell/bin/download_tarball.sh
source "$SETUP_TOOLS_ROOT/$tool/shell/bin/download_tarball.sh"

# Install or update the selected apps
for tool in $APPS; do
  # Skip apps if extra selected but no other
  if [ "$EXTRA_APP_SELECTED" -eq 1 ] && [ "$APP_SELECTED" -ne 1 ]; then
    continue
  fi
  if [[ -f "$SETUP_TOOLS_ROOT/$tool/setup.sh" ]]; then
    echoSection "$tool"
    source "$SETUP_TOOLS_ROOT/$tool/setup.sh"
    if [ "$UPGRADE_APPS" -eq 1 ]; then
      if type "upgrade_$tool" &>/dev/null; then
        "upgrade_$tool"
      fi
    else
      "setup_$tool"
    fi
    ret=$?
    if [[ $ret -eq 0 ]]; then
      echoSectionDone "$tool"
    else
      echoSectionError "$tool (code $ret)"
      case $ret in
        "$SETUP_ERROR_CONTINUE") ;;
        *)
          exit $ret
          ;;
      esac
    fi
  fi
done

custom_tool_folder=$(git --no-pager config -f "$HOME/.common_env.ini" --get install.custom-app-folder 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
if [[ -d "$custom_tool_folder" ]]; then
  if [ -z "$EXTRA_APPS" ]; then
    EXTRA_APPS=$(git --no-pager config -f "$HOME/.common_env.ini" --get-all install.custom-app)
  fi
  for tool in $EXTRA_APPS; do
    # Skip extra apps if not selected while default ones are
    if [ "$APP_SELECTED" -eq 1 ] && [ "$EXTRA_APP_SELECTED" -ne 1 ]; then
      continue
    fi
    if [[ -f "$custom_tool_folder/$tool/setup.sh" ]]; then
      echoSection "$tool"
      source "$custom_tool_folder/$tool/setup.sh"
      if [ "$UPGRADE_APPS" -eq 1 ]; then
        if type "upgrade_$tool" &>/dev/null; then
          "upgrade_$tool"
        fi
      else
        "setup_$tool"
      fi
      ret=$?
      if [[ $ret -eq 0 ]]; then
        echoSectionDone "$tool"
      else
        echoSectionError "$tool (code $ret)"
        case $ret in
          "$SETUP_ERROR_CONTINUE") ;;
          *)
            exit $ret
            ;;
        esac
      fi
    fi
  done
fi

# Update the apps installed in $HOME/.common_env.ini
common_env_app="$(git --no-pager config -f "$HOME/.common_env.ini" --get-all install.app | tr '\n' ' ') $APPS"
common_env_app="$(echo "$common_env_app" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"
git --no-pager config -f "$HOME/.common_env.ini" --unset-all install.app
for app in $common_env_app; do
  git --no-pager config -f "$HOME/.common_env.ini" --add install.app "$app"
done

# Update the path to common_env
echo "$SETUP_ROOT" >"$HOME/.common_env_path"

[[ -f "$HOME/.common_env_check" ]] && rm -f "$HOME/.common_env_check"
echo -e "Setup done.\n"
shellrc=.bashrc
[[ "$(basename "$(system_get_default_shell)")" = "zsh" ]] && shellrc=.zshrc
if [ "$UPGRADE_APPS" -eq 0 ]; then
  echoColor 33 "Please run the following command to complete:"
  echo "source '$HOME/$shellrc'"
  echo
fi
