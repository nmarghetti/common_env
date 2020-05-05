#! /bin/bash

[ "$COMMON_ENV_FULL_DEBUG" = "1" ] && eval "$COMMON_ENV_DEBUG_CMD"

# create_env [python_bin] [version]
function create_env() {
  local pythonbin="python"
  which "$1" &>/dev/null
  if [ $? -eq 0 ]; then
    pythonbin=$(which "$1")
    shift
    unset PYTHONHOME PYTHONPATH
  fi
  local version=$1
  if [ -z "$version" ]; then
    version=$("$pythonbin" --version 2>&1 | cut -d' ' -f2 | tr -d '[[:space:]]')
  fi
  echo "python bin path: '$pythonbin'"
  echo "python version: '$version'"
  if [[ ! "$version" =~ ^[-.a-zA-Z0-9]+$ ]]; then
    echo "Version '$version' is not valid"
    return 1
  fi
  local major_version=$(echo $version | cut -b 1)
  cd && mkdir -p .venv && cd ".venv"
  test $? -ne 0 && echo "Unable to go to .venv in home directory" && return 1
  test -d "$version" && echo "Version '$version' already exist" && return 1
  echo "Create python env '$PWD/$version'"
  if [ "$major_version" = "2" ]; then
    # for python 2
    "$pythonbin" -m virtualenv -h &>/dev/null
    if [ $? -ne 0 ]; then
      "$pythonbin" -m pip install virtualenv && "$pythonbin" -m virtualenv -h &>/dev/null
      [ $? -ne 0 ] && echo "Unable to install virtualenv" && return 1
    fi
    "$pythonbin" -m virtualenv "$version"
  else
    # for python 3
    "$pythonbin" -m venv "$version"
  fi
  [ -d "$major_version" ] && rm -rf "$major_version" # Delete if it is a folder (no symlink on Windows)
  ln -sf "$version" "$major_version"
}

function set_env() {
  version=$1
  test -z "$version" && echo "Please specify version" && return 1
  cd && mkdir -p .venv && cd ".venv"
  test $? -ne 0 && echo "Unable to go to .venv in home directory" && return 1
  test ! -d "$version" && echo "Version $version doest not exist, please create first" && return 1
  local pythonactivate=
  if [ -f "$version/Scripts/activate" ]; then
    pythonactivate="$version/Scripts/activate"
  elif [ -f "$version/bin/activate" ]; then
    pythonactivate="$version/bin/activate"
  else
    echo "Error: Unable to active this python env !"
    return 1
  fi
  # Ensure path to python is posix
  if [ "$(system_get_os_host)" = "Windows" ]; then
    local python_env_path="$(grep -E '^VIRTUAL_ENV=' "$pythonactivate" | head -1 | sed -re "s/VIRTUAL_ENV=(['\"])([^'\"]+)['\"]/\2/")"
    if [ "$(echo "$python_env_path" | grep -c ':')" -ne 0 ]; then
      local python_env_path_posix="$(get_path_to_posix "$python_env_path")"
      sed -re "s#$(echo "$python_env_path" | sed -re "s#\\\\#\\\\\\\\#g")#$python_env_path_posix#g" "$pythonactivate" >|"${pythonactivate}.csh"
      pythonactivate="${pythonactivate}.csh"
    fi
  fi
  source "$pythonactivate"
  type python
}

SAVE_PWD=$PWD
case $1 in
create)
  shift
  create_env "$@"
  ;;
list)
  shift
  if [ -d "$HOME/.venv" ]; then
    ls -1 "$HOME/.venv" | xargs -I X bash -ec 'link=$(readlink "$HOME/.venv/X") || link=; test -n "$link" && link=" -> $link"; echo "X$link"' 2>/dev/null
    [ $? -ne 0 ] && ls -1 "$HOME/.venv"
  fi
  ;;
set)
  shift
  set_env "$@"
  ;;
info)
  echo "* Python"
  type python
  echo && echo "* Python version"
  python -c "import sys; print(sys.version)"
  echo && echo "* Python path"
  python -c "import sys; print('\n'.join(sys.path))"
  echo && echo "* Pip version"
  python -m pip --version
  [[ $? -eq 0 ]] && {
    echo && echo "* Pip config"
    python -m pip config list -v
    echo && echo "* Pip cache"
    python -c "from pip._internal.utils.appdirs import user_cache_dir; print(user_cache_dir('pip')); print(user_cache_dir('wheel'))"
  }
  ;;
*)
  echo "Unknown command '$@', must be create|list|set|info"
  exit 1
  ;;
esac
cd "$SAVE_PWD"
