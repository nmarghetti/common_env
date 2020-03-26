#! /bin/bash

SETUP_SILENT=$(echo "$@" | tr '[:space:]' '\n' | grep -cE '^(-s|--silent)$')

if [ ! "$(uname -s )" = "Darwin" ]; then
  echo "You are not running on Mac, nothing to do."
  exit 1
fi

# Exit if greadlink, gsed, gawk and gecho are there
type greadlink gsed gawk gecho &>/dev/null && exit 0

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
# trap '[[ "${last_command}" =~ ^exit [0-9]+$ ]] || echo "\"${last_command}\" command failed with exit code $?."' EXIT
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT


answer='y'
if [ $SETUP_SILENT -eq 0 ]; then
  echo "Gnu readlink, sed, awk or echo are not available, some components will be installed:"
  echo "  * brew install coreutils"
  echo "  * brew install gnu-sed"
  echo "  * brew install gawk"
  echo "Your shell profile will be update to export PATH to have those new tool in your environment."
  echo "Do you want to proceed ? (Y/n) "
  read answer
fi
[[ ! "$answer" =~ ^[yY]$ ]] && echo "Exit setup." && trap - EXIT && exit 1

# Install modules
brew install coreutils >&2
brew install gnu-sed >&2
brew install gawk >&2

# Chek the shell profile to update
shell_file="$HOME/.bashrc"
if [ -f "$HOME/.zshenv" ]; then
  shell_file="$HOME/.zshenv"
fi
# Setup PATH in the shell profile
path="/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin"
path_to_add="$path"
echo 'export PATH="'$path':$PATH"' >> "$shell_file"
for prog in gawk; do
  for path in /usr/local/Cellar/$prog/*/bin; do
    path_to_add="$path:$path_to_add"
    echo 'export PATH="'$i':$PATH"' >> "$shell_file"
  done
done

if [ $SETUP_SILENT -eq 0 ]; then
  echo "You please run one of the following command to have your PATH up to date:"
  echo " - export PATH='$path_to_add:\$PATH'"
  echo " - source '$shell'"
else
  echo "export PATH=\"$path_to_add:\$PATH\""
fi

trap - EXIT
