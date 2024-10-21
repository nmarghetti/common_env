#! /bin/sh

# This script allow to check if the DNS resolution is working properly
# It would refresh DNS entries in /etc/resolv.conf if the DNS resolution is not working
# This is useful when the network is not stable or while you connect/disconnect from VPN

[ ! -f /opt/wsl_dns.py ] && exit 1
[ ! -f ~/.wsl_check_domain ] && exit 1

# START=$(date +%s.%N)

RESOLV_LOCK_FILE="/tmp/${USER}.resolv.conf.lock"
if (set -o noclobber && printf "DATE:%s\nUSER:%s\nPID:%s\n" "$(date)" "$(whoami)" "$$" >"$RESOLV_LOCK_FILE") 2>/dev/null; then
  trap "rm -f '$RESOLV_LOCK_FILE'; exit $?" EXIT
  # If the resolv.conf file is more than 10 seconds old
  if [ "$(($(date +%s) - $(date -r /etc/resolv.conf +%s)))" -ge 10 ]; then
    while IFS= read -r domain; do
      [ -z "$domain" ] && continue
      if ! nslookup "$domain" >/dev/null 2>&1; then
        /opt/wsl_dns.py >/dev/null 2>&1
        break
      fi
    done <~/.wsl_check_domain
    while IFS= read -r domain; do
      [ -z "$domain" ] && continue
      if ! nslookup "$domain" >/dev/null 2>&1; then
        echo "DNS resolution failed for $domain" >&2
        echo "You might have some network issue." >&2
        break
      fi
    done <~/.wsl_check_domain
  fi
else
  # If the lock is older than 1min, just remove it
  age="$(expr "$(date +%s)" - "$(date -r "$RESOLV_LOCK_FILE" +%s)" 2>/dev/null)"
  if [ -n "$age" ] && [ "$age" -ge 60 ]; then
    echo "Lock older than 5 min, releasing lock '$RESOLV_LOCK_FILE'" >&2
    rm -f "$RESOLV_LOCK_FILE"
  fi
fi

# END=$(date +%s.%N)
# DIFF=$(echo "$END - $START" | bc)
# echo "Execution time for $0: $DIFF seconds" >&2

exit 0
