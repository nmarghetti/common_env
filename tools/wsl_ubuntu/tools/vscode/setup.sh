#! /usr/bin/env bash

setup_vscode() {
  local ERROR=1

  if ! type code >/dev/null 2>&1; then
    curl -Lo code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' &&
      sudo apt install ./code.deb &&
      rm code.deb
  fi

  ! type code >/dev/null 2>&1 && return $ERROR

  return 0
}
