#! /usr/bin/env bash

# https://gist.github.com/trungnt13/4466aa135026c6e21786ea0964f46171
setup_tmux() {
  local ERROR=1
  ! type tmux >/dev/null 2>&1 && sudo apt install -y tmux
  touch ~/.tmux.conf
  mkdir -p ~/.etc
  if [ ! -f ~/.etc/tmux.conf ] || ! cmp --silent ~/.etc/tmux.conf "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/tools/tmux/tmux.conf; then
    cp -vf "$WSL_SETUP_TOOLS_ROOT"/wsl_ubuntu/tools/tmux/tmux.conf ~/.etc/tmux.conf
  fi
  ! type kind >/dev/null 2>&1 && return $ERROR

  grep -qE '^source-file ~/.etc/tmux.conf$' ~/.tmux.conf || echo 'source-file ~/.etc/tmux.conf' >>~/.tmux.conf

  apt list --installed 2>/dev/null | grep -qE '^bash-completion/' || sudo apt install -y bash-completion

  local dir="${BASH_COMPLETION_DIR:-"${XDG_DATA_HOME:-"$HOME/.local/share"}/bash-completion"}/completions"
  mkdir -p "$dir"
  [ -f "$dir/tmux" ] || curl -fSsL "https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux" >"${dir?error: dir not set: you must run the previous commands first}/tmux"

  return 0
}
