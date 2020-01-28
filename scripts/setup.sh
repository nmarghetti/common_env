#! /bin/sh

SETUP_SCRIPT_ROOT=$(dirname "$(readlink -f "$0")")
SETUP_TOOLS_ROOT=$(readlink -f "$SETUP_SCRIPT_ROOT/../tools")

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
  echoColor 31 "Setup for $@ failed !!!"
}

for tool in bash git vscode windows_path python cmake msys2;   do
  if [ -f "$SETUP_TOOLS_ROOT/$tool/setup.sh" ]; then
    echoSection $tool
    source "$SETUP_TOOLS_ROOT/$tool/setup.sh"
    "setup_$tool"
    test $? -ne 0 && echoSectionError $tool && exit 1
    echoSectionDone $tool
  fi
done

echo "Setup done"
