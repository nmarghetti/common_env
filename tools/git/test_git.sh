#! /usr/bin/env bash

# exit when any command fails
set -e
set -o pipefail
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap '[ ! "$FORCE_QUITTING" = "1" ] && echo "\"${last_command}\" command failed with exit code $?."; rm -rf "$TMPDIR"' EXIT
trap 'echo "Quitting..." && FORCE_QUITTING=1 && exit 1' INT

echoStep() {
  echo
  echo
  echo "**************************************** $@ ****************************************"
  echo
  echo
}

showRepoFiles() {
  # type tree &>/dev/null
  # if [ $? -eq 0 ]; then
  #   tree
  # else
  #   find . -name '.git' -prune -o -name '*' -print
  # fi
  ls -la
}

# export GIT_TRACE=1 # to have git trace
# export GIT_CMD_NOCOLOR=1
export TMPDIR=$(mktemp -d)
echo "Create tmp directory: $TMPDIR"
export MAIN=$TMPDIR/main
export FORK=$TMPDIR/fork
export LOCAL=$TMPDIR/local
export MODULE=$TMPDIR/module
export MODULE_OTHER=$TMPDIR/module_other

echoStep "Initialize main repository"
mkdir -p "$MAIN" && cd "$MAIN" && git -c color.ui=always cmd init && git -c color.ui=always br
echo "Read the README" >README.md && git -c color.ui=always a README.md && echo "More to come" >>README.md && touch tmp && echo "tmp" >|.gitignore
git -c color.ui=always ss && git -c color.ui=always sa && git -c color.ui=always add-update && git -c color.ui=always ci "Initial commit" && git -c color.ui=always lg
echo "Ignore tmp" >>README.md && git -c color.ui=always st && git -c color.ui=always add-all && git -c color.ui=always ci 'Update' && git -c color.ui=always st && git -c color.ui=always lg
git -c color.ui=always rs 1 && git -c color.ui=always st && git -c color.ui=always rst README.md && git -c color.ui=always au && git -c color.ui=always commit-amend
git -c color.ui=always co -b develop && git -c color.ui=always co master && git -c color.ui=always lga

echoStep "Initialize fork repository"
mkdir -p "$FORK" && cd "$FORK" && git -c color.ui=always cmd init && git -c color.ui=always cmd remote add origin "$MAIN" && git -c color.ui=always f && git -c color.ui=always branch-checkout-default
git -c color.ui=always branch-checkout origin/develop && git -c color.ui=always branch-all && git -c color.ui=always log-all

echoStep "Initialize submodule"
mkdir -p "$MODULE" && cd "$MODULE" && git -c color.ui=always cmd init && echo "Tooling" >README.md && git -c color.ui=always add-all && git -c color.ui=always ci "Tooling initial commit" && git -c color.ui=always lg

echoStep "Initialize other submodule"
mkdir -p "$MODULE_OTHER" && cd "$MODULE_OTHER" && git -c color.ui=always cmd init && echo "Security" >README.md && git -c color.ui=always add-all && git -c color.ui=always ci "Security initial commit" && git -c color.ui=always lg

echoStep "Add the module and create branch develop to main repository"
cd "$MAIN" && git -c color.ui=always cmd submodule add -- "$MODULE" tooling && git -c color.ui=always cmd submodule add -- "$MODULE_OTHER" security && git -c color.ui=always s && git -c color.ui=always ci 'Add submodules' && git -c color.ui=always lga

echoStep "Clone a local repository"
git -c color.ui=always clones "$FORK" "$LOCAL" && cd "$LOCAL" && git -c color.ui=always upstream "$MAIN" && git -c color.ui=always fetch-upstream && git -c color.ui=always brn "feature_login" && git -c color.ui=always bra && git -c color.ui=always lga
git -c color.ui=always pull upstream master && git -c color.ui=always lga && showRepoFiles && git -c color.ui=always submodule-update && showRepoFiles

echoStep "Add commit in Tooling submodule"
cd "$MODULE" && echo "Some tool" >|tool.sh && git -c color.ui=always aa && git -c color.ui=always ci 'Add tool' && git -c color.ui=always lga

echoStep "Play with submodules in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git -c color.ui=always aa && git -c color.ui=always ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git -c color.ui=always s && git -c color.ui=always df && git -c color.ui=always submodule-update && git -c color.ui=always s && git -c color.ui=always submodule-reset security && git -c color.ui=always s

echoStep "Play more with submodules in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git -c color.ui=always aa && git -c color.ui=always ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git -c color.ui=always s && git -c color.ui=always df && git -c color.ui=always submodule-update security && git -c color.ui=always s && git -c color.ui=always submodule-reset && git -c color.ui=always s

echoStep "Upgrade submodules with changes in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git -c color.ui=always aa && git -c color.ui=always ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git -c color.ui=always s && git -c color.ui=always df && git -c color.ui=always submodule-upgrade security && git -c color.ui=always submodule-upgrade && git -c color.ui=always s && showRepoFiles && git -c color.ui=always df && git -c color.ui=always lga

echoStep "Clean upgrade of submodules in local repository"
cd "$LOCAL" && git -c color.ui=always submodule-reset && git -c color.ui=always s && git -c color.ui=always submodule-upgrade && git -c color.ui=always s && git -c color.ui=always df && git -c color.ui=always add-update && git -c color.ui=always ci "Update submodules" && git -c color.ui=always lga

echoStep "Play with logs"
git -c color.ui=always log-local-default-origin && git -c color.ui=always log-local-default-upstream

echoStep "Play with diffs"
git -c color.ui=always dfsdlu && git -c color.ui=always dfdlu && git -c color.ui=always dfsdl && git -c color.ui=always dfdl

echoStep "Add and reset commits"
echo 'info' >info.txt && git -c color.ui=always aa && git -c color.ui=always ci 'Add info' && echo 'data' >data.txt && git -c color.ui=always aa && git -c color.ui=always ci 'Add data' && git -c color.ui=always lga
git -c color.ui=always reset-commit-last 2 && git -c color.ui=always s && git -c color.ui=always reset-repo && git -c color.ui=always s && git -c color.ui=always aa && git -c color.ui=always ci 'Add info and data' && git -c color.ui=always s && git -c color.ui=always lga
git -c color.ui=always remove-commit-last 1 && git -c color.ui=always lga

echoStep "Add executable file"
touch script.sh && git -c color.ui=always aa && git -c color.ui=always ci 'Add script.sh' && git -c color.ui=always ls && ls -Al
git -c color.ui=always chmodx && git -c color.ui=always s && git -c color.ui=always df && git -c color.ui=always aca && git -c color.ui=always ls && ls -Al && git -c color.ui=always lga

echoStep "List all files"
git -c color.ui=always ls . && git -c color.ui=always lsr && git -c color.ui=always lso

# Clean folder
rm -rf "$TMPDIR"

trap - EXIT
