#! /usr/bin/env bash

setup_google_chrome() {
  local ERROR=1
  if ! type google-chrome >/dev/null 2>&1; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm -f ./google-chrome-stable_current_amd64.deb
  fi

  ! type google-chrome >/dev/null 2>&1 && return $ERROR

  return 0
}
