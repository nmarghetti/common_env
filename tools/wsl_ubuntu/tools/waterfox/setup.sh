#! /usr/bin/env bash

setup_waterfox() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-waterfox.version || echo "6.5.4")
  if [ ! -f /usr/local/waterfox/waterfox ] || ! /usr/local/waterfox/waterfox --version | grep -q "$wishVersion"; then
    curl -sSfLO "https://cdn1.waterfox.net/waterfox/releases/${wishVersion}/Linux_x86_64/waterfox-${wishVersion}.tar.bz2" &&
      sudo tar -xvjf "waterfox-${wishVersion}.tar.bz2" -C /usr/local/ &&
      rm -f "waterfox-${wishVersion}.tar.bz2"
  fi

  [ ! -f /usr/local/waterfox/waterfox ] && return $ERROR

  return 0
}
