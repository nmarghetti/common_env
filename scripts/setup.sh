#! /bin/sh

SCRIPT_NAME=$(basename "$0")
SETUP_SCRIPT_ROOT=$(dirname "$(readlink -f "$0")")
SETUP_TOOLS_ROOT=$(readlink -f "$SETUP_SCRIPT_ROOT/../tools")

APPS="bash git python"

usage() {
  echo "Usage: $SCRIPT_NAME [app [app...] | all]" 1>&2
  echo "  Possible apps:" 1>&2
  echo "    vscode: install Visual Studio Code" 1>&2
  echo "    node: install NodeJs" 1>&2
  echo "    cpp: install make, cmake and GNU C++ compiler" 1>&2
  echo "    xampp: install apache" 1>&2
  echo "    all: install everything above" 1>&2
  echo "In any case it will setup some bash and git config and python" 1>&2
}
while [ $# -gt 0 ]; do
  case $1 in
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
