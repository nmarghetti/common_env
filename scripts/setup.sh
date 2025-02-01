#! /usr/bin/env bash

exit_error() {
  echo "$*" >&2
  exit 1
}

# Check 'readlink -f' is available
readlink -f "$0" &>/dev/null || exit_error "Unable to use 'readlink -f', exiting."

SCRIPT=${BASH_SOURCE[0]}
if [ -z "$SCRIPT" ] || [ "$SCRIPT" = "bash" ]; then
  SCRIPT=$0
fi

SETUP_SCRIPT_ROOT=$(cd "$(dirname "$(readlink -f "$SCRIPT")")" && pwd)
if [ -n "$APPS_ROOT" ] && [ -d "$APPS_ROOT" ]; then
  mkdir -pv "$APPS_ROOT/AppData/Temp"
  log_file="$APPS_ROOT/AppData/Temp/common_env_setup_$(date +%Y_%m_%d-%H_%M.%S).log"
  "$SETUP_SCRIPT_ROOT"/setup_internal.sh "$@" 2>&1 | tee "$log_file"
  echo "Log file available: $(cygpath -w "$log_file")"
  echo "cat $(cygpath -u "$log_file") | less -R"
  echo
else
  "$SETUP_SCRIPT_ROOT"/setup_internal.sh "$@"
fi
