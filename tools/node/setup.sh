#! /bin/bash

function setup_node() {
  nodejs_path="$APPS_COMMON/node"
  # Install NodeJs
  if [ ! -f "$nodejs_path/node.exe" ]; then
    tarball=node-v12.14.1-win-x64.zip
    if [ ! -f $tarball ]; then
      wget --progress=bar:force https://nodejs.org/dist/v12.14.1/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
    fi
    unzip $tarball -d "$APPS_COMMON/" | awk 'BEGIN {ORS="."} {print "."}'
    test $? -ne 0 && echo -e "\nError, unable unzip the archive." && return 1
    mv "$APPS_COMMON/$(basename $tarball .zip)" "$nodejs_path"
    echo
    rm -f $tarball
  fi
  if [ ! -f "$nodejs_path/node.exe" ]; then
    return $SETUP_ERROR_CONTINUE
  fi
  if [ ! -f "$nodejs_path/yarn" ]; then
    "$nodejs_path/npm" install -g yarn
  fi
}
