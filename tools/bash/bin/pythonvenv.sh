#! /bin/bash

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
    version=$($pythonbin --version | cut -d' ' -f2 | tr -d '[[:space:]]')
  fi
  echo "python bin path: $pythonbin"
  echo "python version: $version"
  if [[ ! "$version" =~ ^[-.a-zA-Z0-9]+$ ]]; then
    echo "Version '$version' is not valid"
    return 1
  fi
  cd && mkdir -p .venv && cd ".venv"
  test $? -ne 0 && echo "Unable to go to .venv in home directory" && return 1
  test -d "$version" && echo "Version $version already exist" && return 1
  echo "Create python env $PWD/$version"
  $pythonbin -m venv "$version"
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
    test -d "$HOME/.venv" && ls -1 "$HOME/.venv"
  ;;
  set)
    shift
    set_env "$@"
  ;;
  *)
    echo "Unknown command '$@', must be create|list|set"
    exit 1
esac
cd $SAVE_PWD
