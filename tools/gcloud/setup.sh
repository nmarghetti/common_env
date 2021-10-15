#! /usr/bin/env bash

function setup_gcloud() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local gcloud_path="$APPS_COMMON/gcloud"

  # Install Google cloud SDK
  if [[ ! -f "$gcloud_path/bin/gcloud" ]]; then
    mkdir -vp "$gcloud_path"
    download_tarball -e -d "$gcloud_path" -m "google-cloud-sdk" "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-365.0.1-windows-x86_64-bundled-python.zip"
    [[ ! -f "$gcloud_path/bin/gcloud" ]] && echo "Binary file not installed" && return "$ERROR"
    "$gcloud_path/install.bat" --usage-reporting false --path-update false --quiet
  fi

  return 0
}
