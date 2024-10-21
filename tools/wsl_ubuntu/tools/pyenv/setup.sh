#! /usr/bin/env bash

setup_pyenv() {
  local ERROR=1
  local wishVersion
  wishVersion=$(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get wsl-ubuntu-pyenv.python-version || echo "3.13.0")

  # Install pyenv
  if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
  fi
  [ ! -d "$HOME/.pyenv" ] && return $ERROR
  if ! type pyenv &>/dev/null; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi

  # Install python
  if ! pyenv versions --bare | grep -qE "^$wishVersion\$" || ! python -c "import ssl; print(ssl.OPENSSL_VERSION)" >/dev/null 2>&1; then
    # Install dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
    sudo apt install -y build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev curl git \
      libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    pyenv install -f "$wishVersion"
    pyenv global "$wishVersion" "$wishVersion"
    python -m pip install --upgrade pip
  fi

  # Ensure pip is at least version 24.0
  if ! printf '%s\n%s\n' "$(pip --version | sed -re 's/^[^0-9]+([0-9.]+)[^0-9].+$/\1/')" "24.0" |
    sort -r --check=quiet --version-sort; then
    python -m pip install --upgrade pip
  fi

  local tmp_file
  tmp_file=$(mktemp)
  local name
  local version
  local package

  python -m pip freeze >"$tmp_file"
  for package in $(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get-all wsl-ubuntu-pyenv.package); do
    name=$(echo "$package" | cut -d: -f1)
    version=
    echo "$package" | grep -q ':' && version=$(echo "$package" | cut -d: -f2)
    if ! grep "$name" "$tmp_file" | grep -q "$version"; then
      [ -n "$version" ] && package="$name==$version"
      echo "  * Install package $package"
      python -m pip install --force-reinstall "$package"
    fi
  done
  python -m pipx list >"$tmp_file"
  for package in $(git --no-pager config -f "$WSL_APPS_ROOT/home/.common_env.ini" --get-all wsl-ubuntu-pyenv.pipx-package); do
    name=$(echo "$package" | cut -d: -f1)
    version=
    echo "$package" | grep -q ':' && version=$(echo "$package" | cut -d: -f2)
    if ! grep "$name" "$tmp_file" | grep -q "$version"; then
      [ -n "$version" ] && package="$name==$version"
      echo "  - Install pipx package $package"
      python -m pipx install -f "$package"
    fi
  done
  rm -f "$tmp_file"

  return 0
}
