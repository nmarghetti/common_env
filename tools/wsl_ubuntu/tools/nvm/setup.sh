#! /usr/bin/env bash

setup_nvm() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-nvm.version || echo "0.40.1")

  [ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"
  if [ "$(nvm --version 2>/dev/null)" != "$wishVersion" ]; then
    echo "Installing nvm $wishVersion"
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${wishVersion}/install.sh" | bash
    [ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"
  fi

  [ "$(nvm --version 2>/dev/null)" != "$wishVersion" ] && echo "ERROR: Unable to install nvm" >&2 && return $ERROR

  local nodeVersion
  nodeVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-nvm.node-version)
  if [ -n "$nodeVersion" ]; then
    nvm ls --no-colors "$nodeVersion" >/dev/null || nvm install --default "$nodeVersion"
    nvm use "$nodeVersion"

    local npm_packages_installed
    npm_packages_installed=$(npm list -g --depth 0)
    local packages=
    for package in $(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get-all wsl-ubuntu-nvm.package); do
      echo "$npm_packages_installed" | grep -q "$package" || packages="$packages $package"
    done
    if [[ -n "$packages" ]]; then
      echo "Update npm packages:$packages"
      # shellcheck disable=SC2086
      npm install -g $packages
    fi

  fi

  return 0
}
