#! /usr/bin/env zsh

pathRm() {
  if [ -z "$1" ]; then
    return 1
  fi
  export PATH=$(echo $PATH | tr ':' '\n' | grep -vE "^${1%/}/?\$" | tr '\n' ':')
}

pathAdd() {
  elt=${1%/}
  if [ ! -d "$elt" ]; then
    echo "Error: not adding '$elt' in the PATH, it is not an existing directory" >&2
    return 1
  fi
  pathRm "$elt"
  if [ "$2" = "prepend" ]; then
    export PATH=$PATH:$elt
  else
    export PATH=$elt:$PATH
  fi
}

# append the given path
pathAppend() {
  pathAdd "$@"
}

# insert at the beginning the given path
pathPrepend() {
  pathAdd "$@" prepend
}

# display the path
pathList() {
  echo "$PATH" | tr ":" "\n"
}
