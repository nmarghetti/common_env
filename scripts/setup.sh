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
  loglevel=$(git --no-pager config -f "$HOME/.common_env.ini" --get install.log-level || echo "info")
  loglevel=$(echo "$loglevel" | tr '[:upper:]' '[:lower:]')
  if [ "$loglevel" = "debug" ]; then
    export PS4=$'+ \t\t''\e[33m\s@\v ${BASH_SOURCE:-}#\e[35m${LINENO} \e[34m${FUNCNAME[0]:+${FUNCNAME[0]}() }''\e[36m\t\e[0m\n'
    export COMMON_ENV_FULL_DEBUG=1
  fi
  case $loglevel in
    debug | info)
      mkdir -pv "$APPS_ROOT/AppData/Temp"
      log_file="$APPS_ROOT/AppData/Temp/common_env_setup_$(date +%Y_%m_%d-%H_%M.%S).log"
      common_env_setup_start_time=$(date +%s)
      "$SETUP_SCRIPT_ROOT"/setup_internal.sh "$@" 2>&1 | tee "$log_file"
      common_env_setup_duration=$(($(date +%s) - common_env_setup_start_time))
      echo "Duration of setup: $((common_env_setup_duration / 60))m$((common_env_setup_duration % 60))s"
      echo "Log file available: $(cygpath -w "$log_file")"
      echo "cat $(cygpath -u "$log_file") | less -R"
      echo
      ;;
    *)
      "$SETUP_SCRIPT_ROOT"/setup_internal.sh "$@"
      ;;
  esac
else
  "$SETUP_SCRIPT_ROOT"/setup_internal.sh "$@"
fi
