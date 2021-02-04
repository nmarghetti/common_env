#! /usr/bin/env bash

function setup_nvm() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local nvm_path="$HOME/.nvm/nvm.sh"

  # Install nvm
  if [[ ! -e "$nvm_path" ]]; then
    download_tarball -o - 'https://raw.githubusercontent.com/nmarghetti/nvm/master/install.sh' |
      NVM_INSTALL_VERSION=master NVM_INSTALL_GITHUB_REPO=nmarghetti/nvm bash
  fi
  [[ ! -e "$nvm_path" ]] && echo "Binary file not installed" && return "$ERROR"

  type nvm &>/dev/null || echo "Sourcing '$nvm_path'..." && source "$nvm_path"

  while IFS= read -r parameter; do
    if [[ -n "$parameter" ]]; then
      local cmd="nvm install $parameter"
      echoColor 36 "  * $cmd"
      eval "$cmd"
      [[ "$?" -ne 0 ]] && return "$ERROR"
    fi
  done < <(git --no-pager config -f "$HOME/.common_env.ini" --get-all nvm.install)

  return 0
}
