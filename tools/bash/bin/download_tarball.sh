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
    -e: extract the tarball
    -o <filename>: output tarball filename (guest from last part of url if empty)
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
  local extract=0
  local tarball_type
  [[ "$DOWNLOAD_NO_SSL_CHECK" == "1" ]] && ssl_check=0
  # reset getopts - check https://man.cx/getopts(1)
  OPTIND=1
  while getopts "hied:m:o:t:" opt; do
    case "$opt" in
    i) ssl_check=0 ;;
    e) extract=1 ;;
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

  # Download the tarball
  [[ -z "$tarball" ]] && tarball=$(basename "$url")
  if [[ ! -f "$tarball" ]]; then
    # Check how to download tarball
    local downloader=
    local downloader_option=
    [[ -z "$downloader" ]] && curl --version &>/dev/null && downloader="curl" && downloader_option="--progress-bar -L -o"
    # Change certificate location if /mingw64/ssl/certs/ca-bundle.crt is empty
    # [[ "$downloader" == "curl" ]] && [[ "$(type curl)" == "/mingw64/bin/curl" ]] && downloader_option="--cacert /usr/ssl/certs/ca-bundle.crt $downloader_option"
    [[ -z "$downloader" ]] && wget --version &>/dev/null && downloader="wget" && downloader_option="--progress=bar:force -O"
    [[ -z "$downloader" ]] && "$APPS_ROOT/wget.exe" --version &>/dev/null && downloader="$APPS_ROOT/wget.exe" && downloader_option="--progress=bar:force -O"
    [[ -z "$downloader" ]] && echo "Error: unable to use wget or curl" && return 1
    [[ $ssl_check -eq 0 ]] && {
      [[ "$(basename "$downloader" .exe)" == "wget" ]] && downloader_option="--no-check-certificate $downloader_option"
      [[ "$(basename "$downloader" .exe)" == "curl" ]] && downloader_option="-k $downloader_option"
    }
    local tmp_output=$(mktemp)
    (set -o pipefail && "$downloader" $downloader_option "$tarball" "$url" |& tee "$tmp_output")
    local download_ok=$?
    # Check what to do in case of error
    if [[ $download_ok -ne 0 ]] && [[ $ssl_check -eq 1 ]]; then
      if grep -E "(unable to get local issuer certificate|Unable to locally verify the issuer's authority)" "$tmp_output" &>/dev/null; then
        local answer=y
        read -rep "There is a problem with SSL certificate, do you want to bypass it (Y/n) ? " -i $answer answer
        if [[ "$answer" =~ ^[yY]$ ]]; then
          [[ "$(basename "$downloader")" == "wget" ]] && downloader_option="--no-check-certificate $downloader_option"
          [[ "$(basename "$downloader")" == "curl" ]] && downloader_option="-k $downloader_option"
          "$downloader" $downloader_option "$tarball" "$url"
          download_ok=$?
        fi
      fi
    fi
    rm -f "$tmp_output"

    [[ $download_ok -ne 0 ]] && echo "Error, unable to retrieve the tarball." && return 1
  fi

  # Extract the tarball
  if [[ $extract -eq 1 ]]; then
    # Get tarball type
    [[ -z "$tarball_type" ]] && {
      case "${tarball#*.}" in
      *exe) tarball_type="exe" ;;
      *zip) tarball_type="zip" ;;
      *tar\.gz) tarball_type="tgz" ;;
      *tar\.xz) tarball_type="txz" ;;
      *)
        echo "Error: unable to find the type of tarball with the extension: '${tarball#*.}'"
        return 1
        ;;
      esac
    }

    # Extract
    local cmd
    local err=0
    if [[ "$tarball_type" == "exe" ]]; then
      "$tarball" || err=1
    else
      case "$tarball_type" in
      zip) cmd="unzip '$tarball' -d '${directory%/}/'" ;;
      tgz) cmd="tar -xvf '$tarball' -C '${directory%/}/'" ;;
      txz) cmd="tar -xvJf '$tarball' -C '${directory%/}/'" ;;
      esac
      eval "$cmd" | awk 'BEGIN {ORS="."} {print "."}' || err=1
      echo
      [[ -n "$extracted_directory" ]] && (
        cd "$directory" && cd "$extracted_directory" && mv * ../ && cd .. && rmdir "$extracted_directory"
      )
    fi
    rm -f "$tarball"
    [[ $err -eq 1 ]] && echo -e "\nError, unable to extract the archive." && return 1
  fi

  return 0
}

[[ "$0" == "$BASH_SOURCE" ]] && download_tarball "$@"
