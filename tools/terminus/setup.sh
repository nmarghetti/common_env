#! /usr/bin/env bash

function setup_terminus() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local terminus_path="$APPS_ROOT/PortableApps/Terminus"

  # Install NodeJs
  if [[ ! -f "$terminus_path/Terminus.exe" ]]; then
    local version=$(git ls-remote --refs --tags --quiet --sort='-version:refname' https://github.com/Eugeny/terminus.git | head -1 | sed -re 's#^.*refs/tags/(.*)$#\1#')
    version="${version:-v1.0.126}"

    mkdir -vp "$terminus_path"
    download_tarball -e -d "$terminus_path" "https://github.com/Eugeny/terminus/releases/download/${version}/terminus-${version:1}-portable.zip"

    [[ ! -f "$terminus_path/Terminus.exe" ]] && return "$ERROR"
  fi

  echo "APPS_ROOT = $APPS_ROOT"
  echo "WINDOWS_APPS_ROOT = $WINDOWS_APPS_ROOT"
  mkdir -vp "$terminus_path/data"
  if [[ ! -f "$terminus_path/data/config.yaml" ]]; then
    cp -v "$SETUP_TOOLS_ROOT/terminus/config.yaml" "$terminus_path/data/config.yaml"
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
      "$terminus_path/data/config.yaml"
  fi

  rsync -vau "$SETUP_TOOLS_ROOT/terminus/Terminus" "$APPS_ROOT/PortableApps/"

  return 0
}
