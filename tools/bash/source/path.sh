#! /bin/sh

# Remove all given paths from $PATH, or the variable of the first arg if it starts with %, eg. %LD_LIBRARY_PATH
# a given can be multiple if contaning ':', in that case each path is removed one by one
# eg. pathRm "path with space" anyPath otherPath multiplePath:path2:path3 "multiple path with space:path 1:path 2"
# eg. pathRm %LD_LIBRARY_PATH /usr/bin
function pathRm() {
  if [ $# -gt 0 ]; then
    local pathVar=PATH
    # If first arg starts with '%', it defines the varible to modify
    if [ "${1::1}" = "%" ]; then
      pathVar=${1#%}
      shift
    fi
    
    # Trick: add ':' to avoid to treat special case of first or last element in the path
    local path=:${!pathVar}:
    local pathToRemove
    
    while [ $# -gt 0 ]; do
      # Split $1 by ':' and treat each element one by one
      while read pathToRemove; do
        # Also remove trailing / from the given path
        path=${path/:${pathToRemove%/}:/:}
      done < <(echo $1 | tr ':' '\n')
      shift
    done
    
    # Trick: remove ':' previsouly added
    path=${path#:}
    path=${path%:}
    export $pathVar="$path"
  else
    echo "pathRm [%Variable_to_update] path_to_remove..."
  fi
}

# Add all given paths from $PATH, or the variable of the first arg if it starts with %, eg. %LD_LIBRARY_PATH
# a given can be multiple if contaning ':', in that case each path is added one by one
# eg. pathRm "path with space" anyPath otherPath multiplePath:path2:path3 "multiple path with space:path 1:path 2"
# eg. pathRm %LD_LIBRARY_PATH /usr/bin
function pathAdd() {
  if [ $# -gt 0 ]; then
    local append=1
    if [ "$1" = "prepend" ]; then
      append=0
      shift
    fi
    
    # First remove the path before to add
    pathRm "$@"
    
    local pathVar=PATH
    # If arg starts with '%', it defines the varible to modify
    if [ "${1::1}" = "%" ]; then
      pathVar=${1#%}
      shift
    fi
    
    local path=
    local pathToAdd=
    
    while [ $# -gt 0 ]; do
      # Split $1 by ':' and treat each element one by one
      while read pathToAdd; do
        # Remove trailing / from the given path
        pathToAdd=${pathToAdd%/}
        # Check the path exist
        if [ ! -d "$pathToAdd" ]; then
          echo "Unable to add path that does not exist: '$pathToAdd'" >&2
          # Check the path is not already added
          elif echo ${path} | grep -qE "(^|:)${pathToAdd}(:|\$)"; then
          echo "Warn: adding several time the same path '$pathToAdd'" >&2
        else
          path=$path:$pathToAdd
        fi
      done < <(echo $1 | tr ':' '\n')
      shift
    done
    path=${path#:}
    
    # append
    if [ $append -eq 1 ]; then
      export $pathVar="${!pathVar}:$path"
      # prepend
    else
      export $pathVar="$path:${!pathVar}"
    fi
  else
    echo "pathAdd [prepend] [%Variable_to_update] path_to_add..."
  fi
}

# append the given path
function pathAppend() {
  pathAdd "$@"
}

# insert at the beginning the given path
function pathPrepend() {
  pathAdd prepend "$@"
}

# display the path
alias pathList='echo $PATH | tr ":" "\n"'
