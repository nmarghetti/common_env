#! /bin/bash

function setup_node() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local nodejs_path="$APPS_COMMON/node"

  # Install NodeJs
  if [[ ! -f "$nodejs_path/node.exe" ]]; then
    mkdir -vp "$nodejs_path"
    download_tarball -e -d "$nodejs_path" -m "node-v12.14.1-win-x64" "https://nodejs.org/dist/v12.14.1/node-v12.14.1-win-x64.zip"
  fi
  [[ ! -f "$nodejs_path/node.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Install packages
  local wished_packages="$(git config -f "$HOME/.common_env.ini" --get-all node.package | tr '\n' ' ')"
  if [[ -n "$wished_packages" ]]; then
    local packages=
    local package
    for package in $wished_packages; do
      echoColor 36 "Checking package $package..."
      "$nodejs_path/npm" list -g --depth 0 "$package" &>/dev/null
      [[ $? -ne 0 ]] && packages="$packages $package"
    done
    [[ -n "$packages" ]] && "$nodejs_path/npm" install -g $packages
  fi

  return 0
}
