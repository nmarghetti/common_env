#! /usr/bin/env bash

function setup_tabby() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local tabby_path="$APPS_ROOT/PortableApps/Tabby"

  # Install NodeJs
  if [[ ! -f "$tabby_path/Tabby.exe" ]]; then
    local version=$(git ls-remote --refs --tags --quiet --sort='-version:refname' https://github.com/Eugeny/tabby.git | head -1 | sed -re 's#^.*refs/tags/(.*)$#\1#')
    version="${version:-v1.0.126}"

    mkdir -vp "$tabby_path"
    download_tarball -e -d "$tabby_path" "https://github.com/Eugeny/tabby/releases/download/${version}/tabby-${version:1}-portable.zip"

    [[ ! -f "$tabby_path/Tabby.exe" ]] && return "$ERROR"
  fi

  echo "APPS_ROOT = $APPS_ROOT"
  echo "WINDOWS_APPS_ROOT = $WINDOWS_APPS_ROOT"
  mkdir -vp "$tabby_path/data"
  if [[ ! -f "$tabby_path/data/config.yaml" ]]; then
    cp -v "$SETUP_TOOLS_ROOT/tabby/config.yaml" "$tabby_path/data/config.yaml"
    local remote_machine=$(powershell -Command "Get-ItemPropertyValue -path HKCU:\Software\SimonTatham\PuTTY\Sessions\remote -name HostName" 2>/dev/null)
    local machine_name="$remote_machine"
    # Keep only machine name if not IP
    [[ ! "$machine_name" =~ ^[0-9.]+$ ]] && machine_name=${machine_name%%.*}
    [[ $? -eq 0 ]] && sed -i -r \
      -e "s/name: remote_machine/name: $machine_name/" \
      -e "s/host: remote_machine/host: $remote_machine/" \
      -e "s/user: remote_user/user: ${USER:-${USERNAME}}/" \
      -e "s#%APPS_ROOT%#$WIN_APPS_ROOT#g" \
      -e "s#%WINDOWS_APPS_ROOT%#$(echo $WINDOWS_APPS_ROOT | sed -re 's#\\#\\\\#g')#g" \
      "$tabby_path/data/config.yaml"
  fi

  rsync -vau "$SETUP_TOOLS_ROOT/tabby/Tabby" "$APPS_ROOT/PortableApps/"

  return 0
}
