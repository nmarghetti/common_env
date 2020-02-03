#! /bin/sh

function create_env() {
  local version=$1
  if [ -z "$version" ]; then
    version=$(python --version | cut -d' ' -f2 | tr -d '[[:space:]]')
  fi
  cd && mkdir -p .venv && cd ".venv"
  test $? -ne 0 && echo "Unable to go to .venv in home directory" && return 1
  test -d "$version" && echo "Version $version already exist" && return 1
  echo "Create python env version $version"
  python -m venv "$version"
}

function set_env() {
  version=$1
  test -z "$version" && echo "Please specify version" && return 1
  cd && mkdir -p .venv && cd ".venv"
  test $? -ne 0 && echo "Unable to go to .venv in home directory" && return 1
  test ! -d "$version" && echo "Version $version doest not exist, please create first" && return 1
  source "$version/Scripts/activate"
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
