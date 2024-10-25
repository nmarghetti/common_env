#! /usr/bin/env bash

function download_msys_package() {
  local available_deps_file
  local package
  local package_version
  available_deps_file=$(mktemp)
  rm -f "$available_deps_file"
  download_tarball -o "$available_deps_file" https://repo.msys2.org/msys/x86_64/ || return 1
  cat "$available_deps_file"
  for package in "$@"; do
    package_version=$(grep "$package" "$available_deps_file" | sed -re 's#^[^"]*"([^"]+)".*$#\1#' | grep -E "^${package}-[0-9]" | sort -r --version-sort | head -2 | grep -vE '.sig$' | head -1)
    [ -z "$package_version" ] && echo "Unable to find version for package $package" && return 1
    download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/$package_version" || return 1
  done
  rm -f "$available_deps_file"

  return 0
}

[[ "$0" == "${BASH_SOURCE[0]}" ]] && download_msys_package "$@"
