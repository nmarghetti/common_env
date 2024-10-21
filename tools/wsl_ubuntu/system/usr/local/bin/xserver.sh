#! /bin/bash

SCRIPT_ROOT="$(dirname "$(readlink -f "$0")")"

display_port=0

usage() {
  cat <<EOM
Usage: $0 [options]

Options:
  -d <display_port> : display port to check, default=$display_port
  -h : display this help

It will try amoung all network interfaces to find an X server running with the given port.
EOM
}

echoError() {
  echo "$*" >&2
}

# reset getopts - check https://man.cx/getopts(1)
OPTIND=1
while getopts "hd:" opt; do
  case "$opt" in
    d) display_port=1 ;;
    h)
      usage
      exit 0
      ;;
    \? | *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))
[ $# -ne 0 ] && {
  echoError "Error: No argument accepted."
  usage
  exit 1
}

port=$((6000 + "$display_port"))

if ! host="$("$SCRIPT_ROOT"/hostserver.sh -p "$port" -q)"; then
  echo "No X server found"
  exit 1
fi

DISPLAY="$host:$display_port"
# Update .Xauthority with current X server IP if not there yet
if [ -f ~/.Xauthority ]; then
  if [ "$(xauth list | grep -c "$DISPLAY")" -eq 0 ]; then
    xauthCookie="$(xauth list | grep '/unix' | head -1 | tr -s '[:space:]' | cut -d' ' -f3)"
    if [ -z "$xauthCookie" ]; then
      echo "ERROR: xauth is not properly configured"
    else
      echo "Adding $DISPLAY to ~/.Xauthority"
      xauth add "$DISPLAY" . "$xauthCookie"
    fi
  fi
fi

echo "XServer found, please run those commands to have access to it"
echo 'export LIBGL_ALWAYS_INDIRECT=1'
echo "export DISPLAY=$DISPLAY"
