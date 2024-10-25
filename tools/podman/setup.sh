#! /usr/bin/env bash

# https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md
# $APPS_ROOT\home\.local\share\containers\podman\machine

function setup_podman() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local distribution='podman-machine-portable'
  local upgrade
  local minimumVersion

  # Better integrate in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/podman/Podman" "$APPS_ROOT/PortableApps/"

  # Check for podman version upgrade
  upgrade=0
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get podman.minimum-version || echo "4.7.2")
  if type podman &>/dev/null &&
    ! printf '%s\n%s\n' "$(podman --version | cut -d' ' -f3)" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    upgrade=1
  fi
  # Install podman
  if ! type podman &>/dev/null || [ "$upgrade" = "1" ]; then
    # # If podman already exists, lets clean it all
    # if type podman &>/dev/null; then
    #   # Remove podman WSL distribution
    #   if type wsl &>/dev/null; then
    #     for distribution in $(wsl --list --quiet | iconv -f utf-16le -t utf-8 | dos2unix | grep -E '^podman'); do
    #       wsl --unregister "$distribution"
    #     done
    #   fi
    #   # Remove podman machines
    #   podman machine reset --force
    #   # Remove podman remaning connection
    #   for connection in $(podman system connection list --format "{{.Name}}"); do
    #     podman system connection remove "$connection"
    #   done
    # fi

    download_tarball -o "podman_setup.exe" "https://github.com/containers/podman/releases/download/v${minimumVersion}/podman-${minimumVersion}-setup.exe"
    START //WAIT "$SETUP_TOOLS_ROOT/podman/install_podman.cmd"
    rm -f "podman_setup.exe"
  fi

  # Add docker alias for podman
  rsync -vau "$SETUP_TOOLS_ROOT/podman/docker.sh" "$APPS_ROOT/PortableApps/PortableGit/usr/bin/docker"

  # Remove podman machine if previously set with wrong environment variables
  START //I //WAIT //B //D "$WINDOWS_APPS_ROOT\\PortableApps\\Podman" "$APPS_ROOT/PortableApps/Podman/clean_podman.cmd"
  # Setup podman with the right environment variables
  START //WAIT //B //D "$WINDOWS_APPS_ROOT\\PortableApps\\Podman" "$APPS_ROOT/PortableApps/Podman/setup.cmd"

  ! type podman &>/dev/null && echo "podman not installed, either installation failed, either you need to restart the computer first" && return "$ERROR"

  ! type wsl &>/dev/null && echo "WSL not installed" && return "$ERROR"

  return 0
}
