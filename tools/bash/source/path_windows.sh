#! /usr/bin/env bash

get_path_to_windows() {
  [ -z "$1" ] && echo "Need the location as first parameter" >&2 && return 1
  local location=$1
  [ "$(echo "$location" | cut -b -5)" = "/mnt/" ] && location="$(echo "$location" | cut -b 5-)"
  [ "$(echo "$location" | cut -b -8)" = "/drives/" ] && location="$(echo "$location" | cut -b 8-)"
  [ ! "$(echo "$location" | cut -b 3)" = '/' ] && [ -n "$(echo "$location" | cut -b 3)" ] && echo "Invalid location to convert" >&2 && return 1
  echo "$(echo $location | cut -b 2 | tr '[:lower:]' '[:upper:]'):$(echo "$location" | cut -b 3-)"
}

get_path_to_windows_back() {
  echo "$(get_path_to_windows "$1")" | tr '/' '\\'
}

get_path_to_posix() {
  [ -z "$1" ] && echo "Need the location as first parameter" && return 1
  local location=$1
  local letter=$(echo "$location" | cut -b 1 | tr '[:upper:]' '[:lower:]')
  local letter_prefix=''
  [ -d '/mnt/' ] && letter_prefix='/mnt'
  if [ -d "$letter_prefix/$letter" ]; then
    letter_prefix="$letter_prefix/$letter"
  else
    letter_prefix="$letter_prefix/$(echo $letter | tr '[:lower:]' '[:upper:]')"
  fi
  echo "$letter_prefix$(echo $location | cut -b 3- | tr '\\' '/')"
}
