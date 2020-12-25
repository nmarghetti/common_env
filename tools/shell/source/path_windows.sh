#! /usr/bin/env bash

get_path_to_windows() {
  [ -z "$1" ] && echo "Need the location as first parameter" >&2 && return 1
  local location=$1
  # If not absolute posix path, just return it
  [ ! "$(printf '%s' "$location" | cut -b 1)" = "/" ] && printf '%s\n' "$location" && return 0

  [ "$(printf '%s' "$location" | cut -b -5)" = "/mnt/" ] && location="$(printf '%s' "$location" | cut -b 5-)"
  [ "$(printf '%s' "$location" | cut -b -8)" = "/drives/" ] && location="$(printf '%s' "$location" | cut -b 8-)"
  [ ! "$(printf '%s' "$location" | cut -b 3)" = '/' ] && [ -n "$(printf '%s' "$location" | cut -b 3)" ] && echo "Invalid location to convert" >&2 && return 1
  printf '%s\n' "$(printf '%s' "$location" | cut -b 2 | tr '[:lower:]' '[:upper:]'):$(printf '%s' "$location" | cut -b 3-)"
}

get_path_to_windows_back() {
  printf '%s\n' "$(get_path_to_windows "$1")" | tr '/' '\\'
}

get_path_to_posix() {
  [ -z "$1" ] && echo "Need the location as first parameter" && return 1
  local location=$1
  # If already posix path, just return it
  [ "$(printf '%s' "$location" | cut -b 1)" = "/" ] && printf '%s\n' "$location" && return 0

  local letter=$(printf '%s' "$location" | cut -b 1 | tr '[:upper:]' '[:lower:]')
  local letter_prefix=''
  [ -d '/mnt/' ] && letter_prefix='/mnt'
  if [ -d "$letter_prefix/$letter" ]; then
    letter_prefix="$letter_prefix/$letter"
  else
    letter_prefix="$letter_prefix/$(printf '%s' "$letter" | tr '[:lower:]' '[:upper:]')"
  fi
  printf '%s\n' "$letter_prefix$(printf '%s' "$location" | cut -b 3- | tr '\\' '/')"
}
