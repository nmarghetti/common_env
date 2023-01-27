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

  local minimumVersion
  minimumVersion=$(git --no-pager config -f "$HOME/.common_env.ini" --get gcloud.minimum-version || echo "413.0.0")
  local gcloudVersion
  gcloudVersion=$("$gcloud_path/bin/gcloud.cmd" --version | grep -i google | head -1 | sed -re "s/^[^\.0-9]*([\.0-9]+)[^\.0-9]*$/\1/")
  if ! printf '%s\n%s\n' "$gcloudVersion" "$minimumVersion" |
    sort -r --check=quiet --version-sort; then
    {
      cd "$APPS_ROOT/PortableApps/CommonFiles" || return "$ERROR"
      START //WAIT "$SETUP_TOOLS_ROOT/gcloud/gcloud_update.cmd" "$minimumVersion"
    }
  fi
  if "$gcloud_path/bin/gcloud.cmd" components list | grep -e ' gke-gcloud-auth-plugin ' -e ' kubectl ' | grep -q 'Not Installed'; then
    {
      cd "$APPS_ROOT/PortableApps/CommonFiles" || return "$ERROR"
      START //WAIT "$SETUP_TOOLS_ROOT/gcloud/gcloud_components.cmd" gke-gcloud-auth-plugin kubectl
    }
  fi

  return 0
}
