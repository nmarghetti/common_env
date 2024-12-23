#! /usr/bin/env bash

setup_k9s() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-k9s.version || echo "0.32.4")

  # if ! type k9s >/dev/null 2>&1 || [ ! "$(k9s version --client=true -o json | jq -r '.clientVersion.gitVersion' | sed -re 's/^v?(.*)$/\1/')" = "$wishVersion" ]; then
  if ! type k9s >/dev/null 2>&1; then
    curl -fsSL -o k9s_linux_amd64.deb "https://github.com/derailed/k9s/releases/download/v${wishVersion}/k9s_linux_amd64.deb" &&
      sudo apt install -y ./k9s_linux_amd64.deb &&
      rm ./k9s_linux_amd64.deb
  fi
  ! type k9s >/dev/null 2>&1 && return $ERROR

  return 0
}
