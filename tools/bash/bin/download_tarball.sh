#! /bin/bash

# Help function
download_tarball_usage() {
  [[ -n "$1" ]] && echo -e "$1\n"

  cat <<'HELP'
Download tarball:
  - download the tarball
  - extract it

Usage: download_tarball [option] url
  options:
    -i: ignore ssl certificate check (not secure)
    -o <filename>: output tarball name (guest from last part of url if empty)
    -d <path>: directory where to extract
    -m <dirname>: directory name where files are extracted, if specified move all files from there back to extract directory
    -t <type>: type of tarball: zip, tgz, exe (automatically guest by extension)
    -h: display this help message

Example:
  download_tarball
HELP
}

download_tarball() {
  # Read input parameters
  local tarball
  local url
  local directory=.
  local extracted_directory=
  local ssl_check=1
  local tarball_type
  while getopts hid:m:o:t: opt; do
    case "$opt" in
    i) ssl_check=0 ;;
    o) tarball=$OPTARG ;;
    d) directory=$OPTARG ;;
    m) extracted_directory=$OPTARG ;;
    t)
      case "$OPTARG" in
      zip | tgz | exe) tarball_type=$OPTARG ;;
      *)
        download_tarball_usage "Error: unsupported tarball type: '$tarball_type'."
        return 2
        ;;
      esac
      ;;
    h)
      download_tarball_usage
      return 0
      ;;
    \? | *)
      download_tarball_usage
      return 2
      ;;
    esac
  done
  shift $(expr $OPTIND - 1)
  [[ $# -ne 1 ]] && {
    download_tarball_usage "Error: only one argument allowed: the url."
    return 2
  }
  declare url="$1"

  # Download tarball
  [[ -z "$tarball" ]] && tarball=$(basename "$url")
  [[ -z "$tarball_type" ]] && {
    case "${tarball#*.}" in
    *zip) tarball_type="zip" ;;
    *exe) tarball_type="exe" ;;
    *tar\.gz) tarball_type="tgz" ;;
    *tar\.xz) tarball_type="txz" ;;
    *)
      echo "Error: unable to find the type of tarball with the extension: '${tarball#*.}'"
      return 1
      ;;
    esac
  }

  if [[ ! -f "$tarball" ]]; then
    local extra_opt=
    [[ $ssl_check -eq 0 ]] && extra_opt="--no-check-certificate"
    wget $extra_opt --progress=bar:force -O "$tarball" "$url"
    test $? -ne 0 && echo "Error, unable to retrieve the zip." && return 1
  fi
  local cmd
  local err=0
  case "$tarball_type" in
  zip) cmd="unzip '$tarball' -d '${directory%/}/'" ;;
  tgz | txz) cmd="tar -xvf '$tarball' -C '${directory%/}/'" ;;
  esac
  eval "$cmd" | awk 'BEGIN {ORS="."} {print "."}' || err=1
  echo
  rm -f "$tarball"
  [[ -n "$extracted_directory" ]] && (
    cd "$directory" && cd "$extracted_directory" && mv * ../ && cd .. && rmdir "$extracted_directory"
  )
  [[ $err -eq 1 ]] && echo -e "\nError, unable unzip the archive." && return 1

  return 0
}

[[ "$0" == "$BASH_SOURCE" ]] && download_tarball "$@"
