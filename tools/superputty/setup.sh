#! /bin/bash

function setup_superputty() {
  local ERROR=$SETUP_ERROR_CONTINUE

  superputty_path="$APPS_ROOT/PortableApps/SuperPuTTY"
  # Install SuperPuTTY
  if [[ ! -f "$superputty_path/SuperPutty.exe" ]]; then
    mkdir -vp "$superputty_path"
    download_tarball -o SuperPutty.zip -d "$superputty_path" -m 'SuperPuTTY-1.4.0.9' "https://github.com/jimradford/superputty/releases/download/1.4.0.9/SuperPuTTY-1.4.0.9.zip"
  fi
  [[ ! -f "$superputty_path/SuperPutty.exe" ]] && return $ERROR

  # Better add PuTTY in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/superputty/SuperPuTTY" "$APPS_ROOT/PortableApps/"

  local file
  for file in SuperPuTTY.settings Sessions.XML AutoRestoreLayout.XML; do
    [[ ! -f "$superputty_path/$file" ]] && cp -v "$SETUP_TOOLS_ROOT/superputty/$file" "$superputty_path/"
  done

  return 0
}
