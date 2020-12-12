#! /usr/bin/env bash

function setup_pacman() {
  local ERROR=$SETUP_ERROR_STOP
  # Install pacman
  if [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/pacman.exe" ]]; then
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-5.2.2-4-x86_64.pkg.tar.xz" || exit $ERROR
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-mirrors-20201208-1-any.pkg.tar.xz" || exit $ERROR
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/msys2-keyring-r21.b39fb11-1-any.pkg.tar.xz" || exit $ERROR

    echo "Initializing pacman keys..."
    pacman-key --init
    pacman-key --populate msys2
    pacman-key --refresh-keys
    pacman -Tv
    pacman -Syuv --overwrite='*'

    # Install bash and exit to avoid errors due to replacing current bash
    pacman -Sv --noconfirm --overwrite='*' bash man
    echo "Exit install to avoid errors due to bash that has been updated. Please rerun installation."
    exit 0
  fi

  # Install packages
  local wished_packages="$(git config -f "$HOME/.common_env.ini" --get-all pacman.package | tr '\n' ' ')"
  if [[ -n "$wished_packages" ]]; then
    local packages=
    local package
    for package in $wished_packages; do
      echoColor 36 "Checking package $package..."
      pacman -Qi $package &>/dev/null
      [[ $? -ne 0 ]] && packages="$packages $package"
    done
    if [[ -n "$packages" ]]; then
      pacman -Sv --noconfirm --overwrite='*' $packages

      # Clean packages
      pacman -Sccv --noconfirm
    fi
  fi

  return 0
}
