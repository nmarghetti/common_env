#! /usr/bin/env bash

setup_common_env() {
  local ERROR=1

  # Setup ssh
  mkdir -p ~/.ssh
  [ ! -f ~/.ssh/id_rsa ] && cp -vf "$WSL_APPS_ROOT"/home/.ssh/id_rsa* ~/.ssh/ && chmod 600 ~/.ssh/id_rsa*

  # Setup common env to have shell and git config
  if [ -z "$(git config --global user.email)" ]; then
    git config --global user.name "$USER"
    git config --global user.email "$(git config -f "$WSL_APPS_ROOT/home/.gitconfig" user.email)"
  fi
  if [ ! -d "$HOME/.common_env" ]; then
    git clone https://github.com/nmarghetti/common_env.git "$HOME/.common_env"
    "$HOME/.common_env/scripts/setup.sh" >/dev/null
  fi
  if [ ! -f "$HOME/.common_env/scripts/setup.sh" ]; then
    echo "common_env not installed"
    return $ERROR
  fi

  return 0
}
