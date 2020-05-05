#! /bin/bash

function setup_pacman() {
  # Install pacman
  if [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/pacman.exe" ]]; then
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-5.2.1-6-x86_64.pkg.tar.xz"
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/pacman-mirrors-20200329-1-any.pkg.tar.xz"
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/msys2-keyring-r9.397a52e-1-any.pkg.tar.xz"

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
