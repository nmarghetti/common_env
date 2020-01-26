#! /bin/sh

function setup_bash() {
  if [ ! -z "$HOME" ]; then
    mkdir -vp "$HOME"
  fi
  
  for var in APPS_ROOT HOME; do
    test -z "${!var}" && echo "Error: $var is not set !!!" && return 1
    test ! -d "${!var}" && echo "Error with $var: '${!var}' does not exist !!!" && return 1
  done
  export WIN_APPS_ROOT="$(echo $APPS_ROOT | cut -b 2 | tr '[:lower:]' '[:upper:]'):$(echo $APPS_ROOT | cut -b 3-)"
  
  test -f "$HOME/.bashrc" && return 0
  echo "Create $HOME/.bashrc"
  cat > "$HOME/.bashrc" << EOM
# BEGIN - Automatically generated, you should not touch those lines:
if [ ! "\$(basename "\${BASH_SOURCE[0]}")" = ".bashrc" ]; then
  echo "ERROR !!! Unable to find the path of .bashrc, not sourcing it, many things will probably not work !!!" >&2
  return
fi
export HOME=\$(cd \$(dirname "\${BASH_SOURCE[0]}") && pwd)
source "$(readlink -f "$SETUP_TOOLS_ROOT/bash/source/.bashrc")"
# - END

# Custom settings
EOM
}
