#! /usr/bin/env bash

function install_pacman() {
  local ERROR=$SETUP_ERROR_STOP

  # https://packages.msys2.org/base/pacman
  download_msys_package msys2-keyring pacman-mirrors pacman || return "$ERROR"

  echo "Initializing pacman keys..."
  pacman-key --init
  pacman-key --populate msys2

  return 0
}

# To search for a package
# pacman -Ss package
function setup_pacman() {
  local ERROR=$SETUP_ERROR_STOP

  if [ -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/pacman.exe" ]; then
    local minimumVersion
    minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get pacman.minimum-version || echo "6.0.1")
    local pacmanVersion
    pacmanVersion=$(pacman --version | grep -i pacman | head -1 | sed -re 's#.*(pacman .*)#\1#i' | awk '{ print $2 }' | sed -re 's#^v?(.*)$#\1#')
    if ! printf '%s\n%s\n' "$pacmanVersion" "$minimumVersion" |
      sort -r --check=quiet --version-sort; then
      install_pacman || return "$ERROR"
    fi

  fi

  # Install pacman
  if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/pacman.exe" ]; then
    install_pacman
    # https://sks-keyservers.net/overview-of-pools.php
    # download_tarball -o "/usr/ssl/sks-keyservers.netCA.pem" "https://sks-keyservers.net/sks-keyservers.netCA.pem" || exit $ERROR
    # cp "/mingw64/ssl/sks-keyservers.netCA.pem"
    # echo "hkp-cacert /usr/ssl/sks-keyservers.netCA.pem" >>~/.gnupg/dirmngr.conf

    # Add David Macek key https://github.com/msys2/MSYS2-packages/issues/2058
    download_tarball https://github.com/1480c1.gpg
    pacman-key -a 1480c1.gpg --gpgdir /etc/pacman.d/gnupg/
    rm -f 1480c1.gpg
    grep -q '/etc/pacman.d/gnupg/gpg.conf' /etc/pacman.d/gnupg/gpg.conf || echo "keyserver hkp://keyserver.ubuntu.com" >>/etc/pacman.d/gnupg/gpg.conf
    pacman-key --refresh-keys

    # Kill remaining process that would disturb the installation
    tasklist //FI "IMAGENAME eq gpg-agent.exe" //FO TABLE | grep gpg-agent.exe | awk '{print $2}' | xargs --no-run-if-empty taskkill //F //PID
    tasklist //FI "IMAGENAME eq dirmngr.exe" //FO TABLE | grep dirmngr.exe | awk '{print $2}' | xargs --no-run-if-empty taskkill //F //PID

    # In case of error with keys you can tell pacman not to check keys, update /etc/pacman.conf and set:
    # SigLevel = Never

    pacman -Tv
    pacman -Syuv --overwrite='*'

    # Install bash and exit to avoid errors due to replacing current bash
    pacman -Sv --noconfirm --overwrite='*' bash man

    # Update certificates
    "$SETUP_TOOLS_ROOT"/helper/update_certificate.sh

    echo "Exit install to avoid errors due to bash that has been updated. Please rerun installation."
    exit 0
  fi

  # Install packages
  local wished_packages
  local ERROR=$SETUP_ERROR_STOP
  local available_deps_file
  available_deps_file=$(mktemp)
  pacman -Q | awk '{ print $1 }' >"$available_deps_file"
  wished_packages="$(git --no-pager config -f "$HOME/.common_env.ini" --get-all pacman.package | tr '\n' ' ')"
  if [ -n "$wished_packages" ]; then
    local packages=
    local package
    for package in $wished_packages; do
      echoColor 36 "Checking package $package..."
      if ! grep -qFx "$package" "$available_deps_file"; then
        packages="$packages $package"
      fi
    done
    if [ -n "$packages" ]; then
      echo "Installing $packages"
      # Refresh the keys
      pacman-key --refresh-keys

      pacman -Sv --noconfirm --overwrite='*' $packages || return "$ERROR"

      # Clean packages
      pacman -Sccv --noconfirm

      # Update certificates in case it changes
      "$SETUP_TOOLS_ROOT"/helper/update_certificate.sh
    fi
  fi
  rm -f "$available_deps_file"

  return 0
}
