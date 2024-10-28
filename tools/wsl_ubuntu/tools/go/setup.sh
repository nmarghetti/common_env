#! /usr/bin/env bash

setup_go() {
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-go.version || echo "1.23.2")

  if [ ! -f /usr/local/go/bin/go ] || ! /usr/local/go/bin/go version | grep -q go"${wishVersion}"; then
    sudo rm -rf /usr/local/go &&
      curl -sSL "https://golang.org/dl/go${wishVersion}.linux-amd64.tar.gz" | sudo tar -C /usr/local -xzf -
  fi

  return 0
}
