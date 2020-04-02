#! /bin/bash

[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"

SCRIPT_ROOT=$(dirname "$(readlink -f "$0")")

ORG_CONFIG_FILE="${SCRIPT_ROOT}/../../git/.gitconfig"
CONFIG_FILE="$HOME/.gitconfig"
LOCK_FILE="$CONFIG_FILE.lock"
TMP_FILE="$CONFIG_FILE.tmp"

if [ ! -f "$ORG_CONFIG_FILE" ]; then
  echo "Error: file does not exist: '$ORG_CONFIG_FILE'" >&2
  exit 1
fi

# If gitconfig more recent or force option given, update it
age="$(expr $(date -r "$ORG_CONFIG_FILE" +%s) - $(date -r "$CONFIG_FILE" +%s) 2>/dev/null)"
if ([ $? -eq 0 ] && [ "$age" -ge 0 ]) || [ "$1" = "-f" ]; then
  # Try to get the lock
  if (set -o noclobber && echo -e "DATE:$(date)\nUSER:$(whoami)\nPID:$$" > "$LOCK_FILE") 2>/dev/null; then
    trap "rm -f '$LOCK_FILE'; exit $?" EXIT
    cat "$CONFIG_FILE" | awk -f "${SCRIPT_ROOT}/../bin/generated_content.awk" -v action=replace -v \
    replace_append=1 -v content_file="$ORG_CONFIG_FILE" >| "$TMP_FILE"
    if [ $? -eq 0 ] && [ $(cat "$TMP_FILE" | wc -l) -ne 0 ]; then
      mv "$TMP_FILE" "$CONFIG_FILE"
    fi
  else
    # If the lock is older than 5min, just remove it
    age="$(expr $(date +%s) - $(date -r "$LOCK_FILE" +%s) 2>/dev/null)"
    if [ $? -eq 0 ] && [ "$age" -ge 300 ]; then
      echo "Lock older than 5 min, releasing lock '$LOCK_FILE'"
      rm -f "$LOCK_FILE"
    fi
  fi
fi
