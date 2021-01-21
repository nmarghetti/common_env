#! /usr/bin/env bash

# https://www.elastic.co/downloads/

function setup_elastic() {
  local ERROR=$SETUP_ERROR_CONTINUE
  local elastic_path="$APPS_ROOT/PortableApps/elastic"
  local version=7.10.2

  mkdir -vp "$elastic_path"

  # Install ELK: Elasticsearch, Logstash, Kibana
  local product
  for product in elasticsearch logstash kibana; do
    echoColor 36 "Checking ${product}..."
    local product_path="$elastic_path/$product"
    local product_bin="$product_path/bin/${product}.bat"
    if [[ ! -f "$product_bin" ]]; then
      mkdir -vp "$product_path"
      download_tarball -e -d "$product_path" -m "${product}-${version}.*" "https://artifacts.elastic.co/downloads/${product}/${product}-${version}-windows-x86_64.zip"
    fi
    [[ ! -f "$product_bin" ]] && echo "Binary file for $product not installed" && return "$ERROR"
  done

  # Set some JVM option to be used only from JDK 8 to 13 as not available anymore with JDK 15
  sed -i -re 's/^(-XX:.*(UseConcMarkSweepGC|CMSInitiatingOccupancyFraction|UseCMSInitiatingOccupancyOnly).*$)/8-13:\1/' "$elastic_path/logstash/config/jvm.options"

  # Better add it all in PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/elastic/elastic" "$APPS_ROOT/PortableApps/"
  if [[ ! -f "$elastic_path/App/AppInfo/appicon3.ico" ]]; then
    local nb
    for nb in $(seq 3); do
      cp -vf "$elastic_path/App/AppInfo/appicon.ico" "$elastic_path/App/AppInfo/appicon${nb}.ico"
    done
  fi

  return 0
}
