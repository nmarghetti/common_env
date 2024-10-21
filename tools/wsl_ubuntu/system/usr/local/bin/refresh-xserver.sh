#! /bin/sh

# Update .Xauthority with current X server IP if not there yet
if [ -n "$DISPLAY" ] && [ -f ~/.Xauthority ]; then
  # Try to get the lock to avoid concurrent process to do the same
  AUTH_LOCK_FILE=~/.xauth.lock
  # The result of xauth list would be stored in a file to avoid other calls as it is rather slow
  AUTH_LIST_FILE=~/.xauth.list
  if (set -o noclobber && echo -e "DATE:$(date)\nUSER:$(whoami)\nPID:$$" >"$AUTH_LOCK_FILE") 2>/dev/null; then
    trap "rm -f '$AUTH_LOCK_FILE'; exit $?" EXIT
    if [ ! -f "$AUTH_LIST_FILE" ]; then
      touch "$AUTH_LIST_FILE"
      chmod 600 "$AUTH_LIST_FILE"
    fi
    if [ "$(wc -l <"$AUTH_LIST_FILE")" -ge 10 ]; then
      # Clean up
      head -5 "$AUTH_LIST_FILE" | sponge "$AUTH_LIST_FILE"
      chmod 600 "$AUTH_LIST_FILE"
    fi
    if ! grep -q "$DISPLAY" "$AUTH_LIST_FILE"; then
      xauthCookie="$(xauth list | grep '/unix' | head -1 | tr -s '[:space:]' | cut -d' ' -f3)"
      if [ -z "$xauthCookie" ]; then
        echo "ERROR: xauth is not properly configured"
      else
        xauth add "$DISPLAY" . "$xauthCookie"
        xauth list >"$AUTH_LIST_FILE"
      fi
    fi
  else
    # If the lock is older than 5min, just remove it
    age="$(expr "$(date +%s)" - "$(date -r "$AUTH_LOCK_FILE" +%s)" 2>/dev/null)"
    if [ -n "$age" ] && [ "$age" -ge 300 ]; then
      echo "Lock older than 5 min, releasing lock '$AUTH_LOCK_FILE'"
      rm -f "$AUTH_LOCK_FILE"
    fi
  fi
fi
