#! /usr/bin/env bash

! type podman >/dev/null && echo "You need to install podman first" && exit 1
[ -z "$(podman machine info -f json | jq '.Host.MachineState' | xargs echo)" ] && podman machine start podman-machine-portable

podman "$@"
