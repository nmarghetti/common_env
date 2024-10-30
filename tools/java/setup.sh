#! /usr/bin/env bash

function setup_java() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local java_path="$APPS_COMMON/java"

  # Retrieve version to install
  local java_version
  java_version="$(git --no-pager config -f "$HOME/.common_env.ini" --get java.version || echo 16)"

  local installed_version

  # Check installed version and remove it if not the right one
  if [ -f "$java_path/bin/java.exe" ]; then
    installed_version="$("$java_path"/bin/java.exe --version | grep -E '[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed -re 's/.*[^0-9]([0-9]+\.[0-9]+\.[0-9]+).*/\1/' | cut -d. -f1)"
    if [ ! "$installed_version" = "$java_version" ]; then
      echo "Replacing old java version $installed_version with $java_version..."
      mv -v "$java_path" "${java_path}_${installed_version}"
    else
      echo "Good java version installed: $installed_version"
    fi
  fi

  # Install java
  if [[ ! -f "$java_path/bin/java.exe" ]]; then
    mkdir -vp "$java_path"
    # download_tarball -e -d "$java_path" -m "jdk-16.0.1" -k 'Cookie: oraclelicense=141' \
    #   "https://download.oracle.com/otn-pub/java/jdk/16.0.1+9/7147401fd7354114ac51ef3e1328291f/jdk-16.0.1_windows-x64_bin.zip"

    case "$java_version" in
      8)
        download_tarball -e -d "$java_path" -m "jdk8u292-b10" \
          "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_windows_hotspot_8u292b10.zip"
        ;;
      11)
        download_tarball -e -d "$java_path" -m "jdk-11.0.11+9" \
          "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.zip"
        ;;
      16)
        download_tarball -e -d "$java_path" -m "jdk-16.0.1+9" \
          "https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_windows_hotspot_16.0.1_9.zip"
        ;;
      17)
        download_tarball -e -d "$java_path" -m "jdk-17.0.3+7" \
          "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.3%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.3_7.zip"
        ;;
      18)
        download_tarball -e -d "$java_path" -m "jdk-17.0.3+7" \
          "https://github.com/adoptium/temurin18-binaries/releases/download/jdk-18.0.1%2B10/OpenJDK18U-jdk_x64_windows_hotspot_18.0.1_10.zip"
        ;;
      19)
        download_tarball -e -d "$java_path" -m "jdk-19.0.2+7" \
          "https://github.com/adoptium/temurin19-binaries/releases/download/jdk-19.0.2%2B7/OpenJDK19U-jdk_x64_windows_hotspot_19.0.2_7.zip"
        ;;
      20)
        download_tarball -e -d "$java_path" -m "jdk-20.0.2+9" \
          "https://github.com/adoptium/temurin20-binaries/releases/download/jdk-20.0.2%2B9/OpenJDK20U-jdk_x64_windows_hotspot_20.0.2_9.zip"
        ;;
      21)
        download_tarball -e -d "$java_path" -m "jdk-21.0.2+13" \
          "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jdk_x64_windows_hotspot_21.0.2_13.zip"
        ;;
      *)
        download_tarball -e -d "$java_path" -m "jdk-16.0.1+9" \
          "https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_windows_hotspot_16.0.1_9.zip"
        ;;
    esac
  fi
  [[ ! -f "$java_path/bin/java.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Install certificates
  local ca_bundle
  ca_bundle="$(git config -f "$APPS_ROOT/home/.common_env.ini" install.cacert | sed -re 's#%APPS_ROOT%#'"$(echo "$APPS_ROOT" | sed -re 's#/#\\/#g')"'#')"
  if [ -f "$ca_bundle" ]; then
    local bundle_dir
    local bundle_name
    bundle_dir=$(dirname "$ca_bundle")
    bundle_name=$(basename "$ca_bundle")
    local keytool="$APPS_ROOT/PortableApps/CommonFiles/java/bin/keytool.exe"
    local cacerts="$APPS_ROOT/PortableApps/CommonFiles/java/lib/security/cacerts"
    local cert
    local cert_alias
    while read -r cert; do
      cert=$(echo "$cert" | cut -b 3-)
      cert_alias=$(basename -s '.crt' "$(echo "$cert" | tr '/' '_')")
      cert="$bundle_dir/$cert"
      echo "Installing certificate '$cert' into '$cacerts' with alias '$cert_alias'"
      # if ! "$keytool" -list -keystore "$cacerts" -v | grep -q "$cert_alias"; then
      #   "$keytool" -import -noprompt -v -trustcacerts -file "$cert" -keystore "$cacerts" -alias "$cert_alias"
      # fi
      # if ! "$keytool" -list -keystore "$cacerts" -v | grep -q "$cert_alias"; then
      #   echo "ERROR: Unable to install certificate '$cert' into '$cacerts'"
      # fi
    done < <(cd "$bundle_dir" && find . -not -name "$bundle_name" -type f -name '*.crt')
  else
    echo "Your certificate bundle does not exist: '$ca_bundle'"
  fi

  return 0
}
