#! /usr/bin/env bash

function setup_podmandesktop() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local podmanDesktop="$APPS_ROOT/PortableApps/PodmanDesktop"
  local podmanDesktopExe="$podmanDesktop/podman_desktop.exe"
  local upgrade
  local minimumVersion

  mkdir -p "$podmanDesktop"

  # Check for podman desktop version upgrade
  upgrade=0
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get podman-desktop.minimum-version || echo "1.5.3")
  if [ -f "$podmanDesktopExe" ]; then
    local currentVersion
    currentVersion="$(powershell -Command "(Get-Command $WIN_APPS_ROOT/PortableApps/PodmanDesktop/podman_desktop.exe).Version -join \".\"")"
    if ! printf '%s\n%s\n' "$currentVersion" "$minimumVersion" |
      sort -r --check=quiet --version-sort; then
      upgrade=1
    fi
  fi

  # Install podman desktop
  if [ ! -f "$podmanDesktopExe" ] || [ "$upgrade" = "1" ]; then
    rm -f "$podmanDesktopExe"
    download_tarball -o "$podmanDesktopExe" "https://github.com/containers/podman-desktop/releases/download/v${minimumVersion}/podman-desktop-${minimumVersion}-x64.exe"
  fi

  [ ! -f "$podmanDesktopExe" ] && echo "Error: binary is not installed" && return "$ERROR"

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/podmandesktop/PodmanDesktop" "$APPS_ROOT/PortableApps/"

  return 0
}
