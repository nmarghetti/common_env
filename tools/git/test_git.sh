#! /bin/bash

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

echoStep() {
  echo
  echo
  echo "**************************************** $@ ****************************************"
  echo
  echo
}

export TMPDIR=$(mktemp -d)
echo "Create tmp directory: $TMPDIR"
export MAIN=$TMPDIR/main
export FORK=$TMPDIR/fork
export LOCAL=$TMPDIR/local
export MODULE=$TMPDIR/module

echoStep "Initialize main repository"
mkdir -p "$MAIN" && cd "$MAIN" && git cmd init && echo "Read the README" > README.md && git aa && git ci "Initial commit"
git br
git lg

echoStep "Initialize fork repository"
mkdir -p "$FORK" && cd "$FORK" && git cmd init && git cmd remote add origin "$MAIN" && git f && git brcd
git bra
git lga

echoStep "Clone a local repository"
git clones "$FORK" "$LOCAL" && cd "$LOCAL" && git upstream "$MAIN" && git fu
git bra
git lga

# Clean folder
rm -rf "$TMPDIR"

trap - EXIT
