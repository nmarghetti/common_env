#! /usr/bin/env bash

# Check it is ran with bash
if [ ! "$(basename "$SHELL")" = "bash" ]; then
  echo "Please run with: bash $0" >&2
  exit 1
fi

SETUP_SILENT=$(echo "$@" | tr '[:space:]' '\n' | grep -cE '^(-s|--silent)$')

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'set +e && echo "\"${last_command}\" command failed with exit code $?."' EXIT

if [ ! "$(uname -s)" = "Darwin" ]; then
  echo "You are not running on Mac, nothing to do."
  exit 1
fi

NEED_INSTALL=0
# Install if greadlink, gecho, gsed, gawk or gxargs are not all there
test $(type greadlink gecho gsed gawk gxargs 2>&1 >/dev/null | wc -l) -eq 0 || NEED_INSTALL=1
if [ $NEED_INSTALL -eq 1 ]; then
  answer='y'
  if [ $SETUP_SILENT -eq 0 ]; then
    echo "Gnu readlink, sed, awk or echo are not available, some components will be installed:"
    echo "  * brew install coreutils"
    echo "  * brew install findutils"
    echo "  * brew install gnu-sed"
    echo "  * brew install gawk"
    echo "Do you want to proceed ? (Y/n) "
    read -r answer
  else
    echo "Using silent mode" >&2
  fi
  [[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1

  # Install modules
  brew install coreutils >&2 # greadlink, gecho
  brew install gnu-sed >&2   # gsed
  brew install gawk >&2      # gawk
  brew install findutils >&2 # gxargs

  # Check installation
  type greadlink gecho gsed gawk gxargs
  greadlink -f "$0" | gxargs -I '{}' --no-run-if-empty gecho -en "args: \e[33m{}\e[0m" | gsed -re 's/args/script/' | gawk '{ print $0 }'
fi

# Check path to add
path_to_add="/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/findutils/libexec/gnubin"
for prog in gawk; do
  for path in /usr/local/Cellar/$prog/*/bin; do
    path_to_add="$path:$path_to_add"
  done
done

export PATH="$path_to_add:$PATH"
export COMMON_ENV_SETUP_MAC_PATH="export PATH=\"$path_to_add:\$PATH\""

# type readlink echo sed awk xargs
readlink -f "$0" | xargs -I '{}' --no-run-if-empty echo -en "args: \e[32m{}\e[0m" | sed -re 's/args/script/' | awk '{ print $0 }' &>/dev/null && echo "MAC setup completed"

# undo in case this file is sourced
set +e
trap - EXIT
