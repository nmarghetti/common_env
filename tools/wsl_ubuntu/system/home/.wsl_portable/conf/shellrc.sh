#! /bin/sh

if [ -f ~/.Xauthority ] && [ -z "$DISPLAY" ]; then
  # Check for X server
  xserver="$(head -1 ~/.last_windows_host.txt 2>/dev/null | tr -d '[:space:]')"
  # Ensure the last IP used (if any) is still part of local ips
  [ -n "$xserver" ] && ! (hostserver.sh -d | grep -q "$xserver") && unset xserver
  if [ -z "$xserver" ] || ! ping -c 1 -W 1 "$xserver" >/dev/null 2>&1; then
    # Try to get the ip address quick
    xserver=$(timeout 1 bash /usr/local/bin/hostserver.sh -q 2>/dev/null)
    # Try a bit longer to get the ip in parallel
    [ -z "$xserver" ] && xserver=$(timeout 3 bash /usr/local/bin/hostserver.sh -qf 2>/dev/null)
    [ -n "$xserver" ] && echo "$xserver" >~/.last_windows_host.txt
    # Do it in the background if still not found, it would at least update ~/.last_windows_host.txt for next session
    [ -z "$xserver" ] && hostserver.sh -qf -s ~/.last_windows_host.txt >/dev/null 2>&1
  fi
  if [ -n "$xserver" ]; then
    export LIBGL_ALWAYS_INDIRECT=1
    export DISPLAY="$xserver":0
    # Set xpaste alias that would give the clipboard data from X server
    alias xpaste='xclip -o | xargs -r echo'

    # Ensure the config for X server
    /usr/local/bin/refresh-xserver.sh &
  fi
  unset xserver
fi

if [ -n "$XDG_RUNTIME_DIR" ] && [ ! -d "$XDG_RUNTIME_DIR" ]; then
  sudo mkdir -p "$XDG_RUNTIME_DIR" && sudo chown "$USER" "$XDG_RUNTIME_DIR"
fi

# Add pipx binary, go in the path
pathAppend ~/.local/bin /usr/local/go/bin >/dev/null 2>&1

alias dockerd_kill="pgrep dockerd | xargs --no-run-if-empty sudo kill"

# For some reason python is not able to find the certificates
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# It can also happen for npm
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
