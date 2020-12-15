#! /usr/bin/env bash

msys_ln() {
  local source
  local dest
  local type='/H'
  local force=0
  while [[ $# -ge 1 ]]; do
    case $1 in
    -f | --force) force=1 ;;
    -v | --version | -h | --help)
      type "$FUNCNAME"
      return 1
      ;;
    -P | --physical) type='/H' ;;
    -s | --symbolic) type='/D' ;;
    -sf)
      force=1
      type='/D'
      ;;
    -*) echo "Unsupported option '$1'" && return 1 ;;
    *) break ;;
    esac
    shift
  done
  source="$1"
  [[ -z "$source" ]] && echo "Missing source link" && return 1
  dest="$2"
  [[ -z "$dest" ]] && dest="$(basename "$source")"
  [[ "$source" != "$dest" && $force -eq 1 && -e "$dest" ]] && rm -f "$dest"
  [[ -e "$dest" ]] && return 1
  # cmd <<<$(echo "mklink $type \"$dest\" \"$source\"") >/dev/null
  cmd.exe /C "mklink $type \"$dest\" \"$source\"" >/dev/null
}
