#! /usr/bin/env bash

# To search for a package
# pacman -Ss package
function setup_pacman() {
  local ERROR=$SETUP_ERROR_STOP
  # Install pacman
  if [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/pacman.exe" ]]; then
    # https://packages.msys2.org/base/pacman
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/msys2-keyring-1~20231013-1-any.pkg.tar.zst" || exit "$ERROR"
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-mirrors-20221016-1-any.pkg.tar.zst" || exit "$ERROR"
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-6.0.2-9-x86_64.pkg.tar.zst" || exit "$ERROR"
    # https://sks-keyservers.net/overview-of-pools.php
    # download_tarball -o "/usr/ssl/sks-keyservers.netCA.pem" "https://sks-keyservers.net/sks-keyservers.netCA.pem" || exit $ERROR
    # cp "/mingw64/ssl/sks-keyservers.netCA.pem"
    # echo "hkp-cacert /usr/ssl/sks-keyservers.netCA.pem" >>~/.gnupg/dirmngr.conf

    echo "Initializing pacman keys..."
    pacman-key --init
    pacman-key --populate msys2

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
  wished_packages="$(git --no-pager config -f "$HOME/.common_env.ini" --get-all pacman.package | tr '\n' ' ')"
  if [[ -n "$wished_packages" ]]; then
    local packages=
    local package
    for package in $wished_packages; do
      echoColor 36 "Checking package $package..."
      if ! pacman -Qi "$package" &>/dev/null; then
        packages="$packages $package"
      fi
    done
    if [[ -n "$packages" ]]; then
      # Refresh the keys
      pacman-key --refresh-keys

      pacman -Sv --noconfirm --overwrite='*' $packages || return "$ERROR"

      # Clean packages
      pacman -Sccv --noconfirm

      # Update certificates in case it changes
      "$SETUP_TOOLS_ROOT"/helper/update_certificate.sh
    fi
  fi

  return 0
}
