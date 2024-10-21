#! /usr/bin/env bash

setup_xserver() {
  local ERROR=1

  # Setup xauth
  [ ! -f ~/.Xauthority ] && [ -f "$WSL_APPS_ROOT"/home/.Xauthority ] && cp -vf "$WSL_APPS_ROOT"/home/.Xauthority ~/
  [ ! -f ~/.Xauthority ] && echo "No ~/.Xauthority file found" && return $ERROR
  if [ "$(xauth list | grep -c '/unix')" -eq 0 ]; then
    xauth add "localhost:0" . "$(mcookie)"
    xauth -f "$WSL_APPS_ROOT"/home/.Xauthority merge ~/.Xauthority
  fi

  return 0
}
