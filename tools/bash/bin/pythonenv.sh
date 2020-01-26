#! /bin/sh

function create_env() {
  version=$1
  if [ -z "$version" ]; then
    version=$(python --version | cut -d' ' -f2 | tr -d '[[:space:]]')
  fi
  cd && mkdir -p .venv && cd ".venv" || ( echo "Unable to go to .venv in home directory" && return )
  test -d "$version" && echo "Version $version already exist" && return
  echo "Create python env version $version"
  python -m venv "$version"
}

function set_env() {
  version=$1
  test -z "$version" && echo "Please specify version" && return
  cd && mkdir -p .venv && cd ".venv" || ( echo "Unable to go to .venv in home directory" && return )
  test -d "$version" || ( echo "Version $version doest not exist, please create first" && return )
  source "$version/Scripts/activate"
  type python
}

case $1 in
  create)
    shift
    (create_env "$@")
    ;;
  list)
    shift
    test -d "$HOME/.venv" && ls -1 "$HOME/.venv"
    ;;
  set)
    shift
    (set_env "$@")
    ;;
  *)
    echo "Unknown command '$@', must be create|list|set"
    exit 1
esac
