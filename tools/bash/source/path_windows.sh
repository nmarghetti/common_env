#! /usr/bin/env bash

get_path_to_windows() {
  [ -z "$1" ] && echo "Need the path as first parameter" >&2 && return 1
  local path=$1
  [ "$(echo "$path" | cut -b -5)" = "/mnt/" ] && path="$(echo "$path" | cut -b 5-)"
  [ "$(echo "$path" | cut -b -8)" = "/drives/" ] && path="$(echo "$path" | cut -b 8-)"
  [ ! "$(echo "$path" | cut -b 3)" = '/' ] && [ -n "$(echo "$path" | cut -b 3)" ] && echo "Invalid path to convert" >&2 && return 1
  echo "$(echo $path | cut -b 2 | tr '[:lower:]' '[:upper:]'):$(echo "$path" | cut -b 3-)"
}

get_path_to_windows_back() {
  echo "$(get_path_to_windows "$1")" | tr '/' '\\'
}

get_path_to_posix() {
  [ -z "$1" ] && echo "Need the path as first parameter" && return 1
  local path=$1
  local letter=$(echo "$path" | cut -b 1 | tr '[:upper:]' '[:lower:]')
  local letter_prefix=''
  [ -d '/mnt/' ] && letter_prefix='/mnt'
  if [ -d "$letter_prefix/$letter" ]; then
    letter_prefix="$letter_prefix/$letter"
  else
    letter_prefix="$letter_prefix/$(echo $letter | tr '[:lower:]' '[:upper:]')"
  fi
  echo "$letter_prefix$(echo $path | cut -b 3- | tr '\\' '/')"
}
