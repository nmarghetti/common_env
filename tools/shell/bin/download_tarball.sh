#! /usr/bin/env bash

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
    -c: ca certificate path
    -k <cookie>: cookie to pass, eg. 'Cookie: key=value; other=something'
    -v: verbose
    -e: extract the tarball
    -o <filename>: output tarball filename (guest from last part of url if empty) or '-' to write it to stdout
    -d <path>: directory where to extract
    -m <dirname>: directory name (can be regexp) where files are extracted, if specified move all files from there back to extract directory
    -t <type>: type of tarball: zip, tgz, zst, exe (automatically guest by extension)
    -p <path>: path to the command to use to download, eg. wget, /usr/bin/curl, etc.
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
  local cacert=
  local extract=0
  local tarball_type
  local downloader=
  local verbose=
  local cookie
  [[ "$DOWNLOAD_NO_SSL_CHECK" == "1" ]] && ssl_check=0
  # reset getopts - check https://man.cx/getopts(1)
  OPTIND=1
  while getopts "hviec:d:k:m:o:t:p:" opt; do
    case "$opt" in
      i) ssl_check=0 ;;
      c) cacert=$OPTARG ;;
      k) cookie=$OPTARG ;;
      e) extract=1 ;;
      o) tarball=$OPTARG ;;
      d) directory=$OPTARG ;;
      m) extracted_directory=$OPTARG ;;
      p) downloader=$OPTARG ;;
      v) verbose="-v" ;;
      t)
        case "$OPTARG" in
          zip | tgz | zst | exe) tarball_type=$OPTARG ;;
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
  if [[ "$tarball" = "-" || ! -f "$tarball" ]]; then
    # Check how to download tarball
    local downloader_option
    declare -A downloader_option=(
      [curl]="$verbose --progress-bar -L"
      [wget]="$verbose --progress=bar:force"
    )
    if [[ -n "$cookie" ]]; then
      downloader_option[curl]="${downloader_option[curl]} -H '$cookie'"
      downloader_option[wget]="${downloader_option[wget]} --header '$cookie'"
    fi
    if [[ "$tarball" = "-" ]]; then
      downloader_option[wget]="${downloader_option[wget]} -O -"
      unset tarball
    else
      downloader_option[curl]="${downloader_option[curl]} -o"
      downloader_option[wget]="${downloader_option[wget]} -O"
    fi
    local downloader_option_nossl
    declare -A downloader_option_nossl=(
      [curl]="-k"
      [wget]="--no-check-certificate"
    )
    local downloader_option_cacert
    declare -A downloader_option_cacert=(
      [curl]="--cacert"
      [wget]="--ca-certificate"
    )
    [[ -z "$downloader" ]] && curl --version &>/dev/null && downloader="curl"
    # Change certificate location if /mingw64/ssl/certs/ca-bundle.crt is empty
    # [[ "$downloader" == "curl" ]] && [[ "$(type curl)" == "/mingw64/bin/curl" ]] && downloader_option="--cacert /usr/ssl/certs/ca-bundle.crt $downloader_option"
    [[ -z "$downloader" ]] && wget --version &>/dev/null && downloader="wget"
    [[ -z "$downloader" ]] && "$APPS_ROOT/wget.exe" --version &>/dev/null && downloader="$APPS_ROOT/wget.exe"
    [[ -z "$downloader" ]] && echo "Error: unable to use wget or curl" && return 1
    local downloader_name="$(basename "$downloader" .exe)"
    local option="${downloader_option[$downloader_name]}"
    [[ -n "$tarball" ]] && option="$option '$tarball'"
    [[ $ssl_check -eq 0 ]] && option="${downloader_option_nossl[$downloader_name]} $option"
    [[ -n "$cacert" ]] && option="${downloader_option_cacert[$downloader_name]} '$cacert' $option"
    local tmp_output=$(mktemp)
    # Would be better not to use eval but did not find a way to handle parameters with space in it
    (set -o pipefail && eval "'$downloader' $option '$url'" 2> >(tee -a "$tmp_output" >&2) | cat)
    local download_ok=$?
    # Check what to do in case of error
    if [[ $download_ok -ne 0 ]] && [[ $ssl_check -eq 1 ]]; then
      if grep -E "(unable to get local issuer certificate|Unable to locally verify the issuer's authority|server certificate verification failed)" "$tmp_output" &>/dev/null; then
        local answer=y
        read -rep "There is a problem with SSL certificate, do you want to bypass it (Y/n) ? " -i $answer answer
        if [[ "$answer" =~ ^[yY]$ ]]; then
          option="${downloader_option_nossl[$downloader_name]} $option"
          eval "'$downloader' $option '$url'"
          download_ok=$?
        fi
      fi
    fi
    rm -f "$tmp_output"

    [[ $download_ok -ne 0 ]] && echo "Error, unable to retrieve the tarball." && return 1
  fi

  # Do not go further when printed to stdout
  [[ -z "$tarball" ]] && return 0

  # Extract the tarball
  if [[ $extract -eq 1 ]]; then
    # Get tarball type
    [[ -z "$tarball_type" ]] && {
      case "${tarball#*.}" in
        *exe) tarball_type="exe" ;;
        *zip) tarball_type="zip" ;;
        *tar\.gz) tarball_type="tgz" ;;
        *tar\.xz) tarball_type="txz" ;;
        *zst) tarball_type="zst" ;;
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
        zst) cmd="tar -I zstd -xvf '$tarball' -C '${directory%/}/'" ;;
      esac
      eval "$cmd" | awk 'BEGIN {ORS="."; limit=40; for(c=0; c<limit*2;c++){back=back"\b"; space=space" ";} } {print "."; if (NR % limit == 0) printf back space back }' || err=1
      echo
      if [[ -n "$extracted_directory" ]]; then
        local subdir="$directory/$extracted_directory"
        if [ ! -d "$subdir" ]; then
          subdir="$directory/$(command ls -1 "$directory" | grep -Ee "$extracted_directory")"
          # Ensure there is only one folder matching
          test "$(echo "$subdir" | wc -l)" -eq 1 || subdir=""
        fi
        (
          cd "$subdir" && mv ./* ../ && cd .. && rmdir "$extracted_directory"
        )
      fi
    fi
    rm -f "$tarball"
    [[ $err -eq 1 ]] && echo -e "\nError, unable to extract the archive." && return 1
  fi

  return 0
}

[[ "$0" == "${BASH_SOURCE[0]}" ]] && download_tarball "$@"
