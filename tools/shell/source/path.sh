#! /usr/bin/env sh

# Remove all given paths from PATH or the variable from the first arg if it starts with %, eg. %LD_LIBRARY_PATH
pathRm() {
  local pathVar
  pathVar=PATH
  if [ "${1::1}" = "%" ]; then
    pathVar=${1#%}
    shift
  fi
  [ $# -eq 0 ] && echo "pathRm [%variable] path [path...]" >&2 && return 1

  local paths
  local location
  paths=${!pathVar}
  for location in "$@"; do
    paths=$(printf "%s" "${paths}" | command tr ':' '\n' | command grep -vE -e "^${location%/}/?\$" -e '^$' | command tr '\n' ':')
  done
  export "$pathVar"="${paths%:}"

  return 0
}

# Add all given paths to PATH or the variable from the first arg if it starts with %, eg. %LD_LIBRARY_PATH
pathAdd() {
  local prepend
  prepend=0
  if [ "$1" = "prepend" ]; then
    prepend=1
    shift
  fi

  local pathVar
  pathVar=PATH
  if [ "${1::1}" = "%" ]; then
    pathVar=${1#%}
    shift
  fi
  [ $# -eq 0 ] && echo "pathAdd [%variable] path [path...]" >&2 && return 1

  # Remove paths before to add
  pathRm "%$pathVar" "$*"

  local paths
  local location
  paths=${!pathVar}
  for location in "$@"; do
    location="${location%/}"
    if [ ! -d "$location" ]; then
      echo "Unable to add path that does not exist: '$location'" >&2
    elif [ $prepend -eq 1 ]; then
      paths="$location:$paths"
    else
      paths="$paths:$location"
    fi
  done
  export "$pathVar"="${paths%:}"

  return 0
}

# append the given path
pathAppend() {
  pathAdd "$@"
}

# insert at the beginning the given path
pathPrepend() {
  pathAdd prepend "$@"
}

# display the path
pathList() {
  printf "%s\n" "$PATH" | command tr ":" "\n"
}
