#! /usr/bin/env bash

function setup_pyenv() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local pyenv_path="$HOME/.pyenv"

  # Install pyenv
  if [[ ! -e "$pyenv_path" ]]; then
    git clone https://github.com/pyenv-win/pyenv-win.git "$pyenv_path"
  fi

  export PATH="$pyenv_path/pyenv-win/bin:$pyenv_path/pyenv-win/shims:$PATH"
  export PYENV="$pyenv_path/pyenv-win"
  export PYENV_ROOT="$pyenv_path/pyenv-win"
  export PYENV_HOME="$pyenv_path/pyenv-win"

  ! type pyenv &>/dev/null && echo "Unable to install pyenv" && return "$ERROR"

  local version
  version=$(git --no-pager config -f "$HOME/.common_env.ini" --get pyenv.install)
  export PYENV_VERSION="$version"
  if ! pyenv versions --bare | grep -qE "^$version\$"; then
    pyenv install "$version"
    pyenv 'local' "$version"
    pyenv global "$version"
    python -m pip install --upgrade pip
  fi
  local wished_packages
  wished_packages="$(git --no-pager config -f "$HOME/.common_env.ini" --get-all pyenv.package | tr '\n' ' ')"
  # If pipx is whished, set some environment variables to configure it
  if echo "$wished_packages" | grep -q pipx; then
    export PIPX_HOME="$HOME/.local/pipx"
    export PIPX_BIN_DIR="$HOME/.local/bin"
    mkdir -p "$PIPX_HOME" "$PIPX_BIN_DIR"
    export PATH="$PIPX_BIN_DIR:$PATH"
  fi
  if [ -n "$wished_packages" ]; then
    # shellcheck disable=SC2086
    pip install $wished_packages
  fi

  return 0
}
