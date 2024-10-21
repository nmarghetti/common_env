#! /usr/bin/env bash

setup_tmux() {
  ! type tmux >/dev/null 2>&1 && sudo apt install -y tmux
  touch ~/.tmux.conf
  mkdir -p ~/.etc
  if [ ! -f ~/.etc/tmux.conf ] || ! cmp --silent ~/.etc/tmux.conf "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/tools/tmux/tmux.conf; then
    cp -vf "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/tools/tmux/tmux.conf ~/.etc/tmux.conf
  fi
  grep -qE '^source-file ~/.etc/tmux.conf$' ~/.tmux.conf || echo 'source-file ~/.etc/tmux.conf' >>~/.tmux.conf

  return 0
}
