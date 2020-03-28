#! /bin/bash

# Check it is ran with bash
if [ ! "$(basename "$SHELL")" = "bash" ]; then
  echo "Please run with: bash $0" >&2
  exit 1
fi

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'set +e && echo "\"${last_command}\" command failed with exit code $?."' EXIT

SETUP_SILENT=$(echo "$@" | tr '[:space:]' '\n' | grep -cE '^(-s|--silent)$')

if [ ! "$(uname -s )" = "Darwin" ]; then
  echo "You are not running on Mac, nothing to do."
  exit 1
fi

NEED_INSTALL=0
# Install if greadlink, gsed, gawk and gecho are not all there
type greadlink gsed gawk gecho &>/dev/null || NEED_INSTALL=1
if [ $NEED_INSTALL -eq 1 ]; then
  answer='y'
  if [ $SETUP_SILENT -eq 0 ]; then
    echo "Gnu readlink, sed, awk or echo are not available, some components will be installed:"
    echo "  * brew install coreutils"
    echo "  * brew install gnu-sed"
    echo "  * brew install gawk"
    echo "Do you want to proceed ? (Y/n) "
    read answer
  else
    echo "Using silent mode" >&2
  fi
  [[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1

  # Install modules
  brew install coreutils >&2
  brew install gnu-sed >&2
  brew install gawk >&2
fi

# Check path to add
path_to_add="/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin"
for prog in gawk; do
  for path in /usr/local/Cellar/$prog/*/bin; do
    path_to_add="$path:$path_to_add"
  done
done

export PATH="$path_to_add:$PATH"
export COMMON_ENV_SETUP_MAC_PATH="export PATH=\"$path_to_add:\$PATH\""

type readlink sed awk echo >/dev/null && echo "MAC setup completed"


# undo in case this file is sourced
set +e
trap - EXIT
