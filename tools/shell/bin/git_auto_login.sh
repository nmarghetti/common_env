#! /usr/bin/env bash

set -e

machine=$1
login=$2
password=$3

if [ -z "$machine" ]; then
  machine=$(git config remote.origin.url | grep -E '^http' | sed -re 's#^[^/]+//([^/]+)/.*$#\1#')
  if [ -n "$machine" ]; then
    if [ "$(echo "$machine" | grep -c '@')" -eq 1 ]; then
      login="$(echo "$machine" | cut -d'@' -f1)"
      machine="$(echo "$machine" | cut -d'@' -f2)"
    fi
    [ "$(echo "$machine" | grep -c ':')" -eq 1 ] && machine="$(echo "$machine" | cut -d':' -f1)"
    [ -z "$login" ] && login=${USER:-${USERNAME}}
  fi
fi

for var in machine login password; do
  prompt="$(echo $var | cut -b 1 | tr '[:lower:]' '[:upper:]')$(echo $var | cut -b 2-): "
  if [ -z "${!var}" ]; then
    [ "$var" = "password" ] && answer=$(read_secret "$prompt")
    [ ! "$var" = "password" ] && read -p "$prompt" answer
    [ -z "${answer}" ] && echo "Error: empty $var" >&2 && exit 1
    eval "$var='$answer'"
  else
    echo "$prompt${!var}"
  fi
done

touch ~/.netrc
chmod 600 ~/.netrc

sed -i -n "/^machine $machine\$/,+3!"p ~/.netrc

cat >>~/.netrc <<EOM
machine $machine
login $login
password $password

EOM
