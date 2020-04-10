#! /bin/bash

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
export GIT_CMD_NOCOLOR=1
export TMPDIR=$(mktemp -d)
echo "Create tmp directory: $TMPDIR"
export MAIN=$TMPDIR/main
export FORK=$TMPDIR/fork
export LOCAL=$TMPDIR/local
export MODULE=$TMPDIR/module
export MODULE_OTHER=$TMPDIR/module_other

echoStep "Initialize main repository"
mkdir -p "$MAIN" && cd "$MAIN" && git cmd init && git br
echo "Read the README" >README.md && git a README.md && echo "More to come" >>README.md && touch tmp && echo "tmp" >|.gitignore
git ss && git sa && git add-update && git ci "Initial commit" && git lg
echo "Ignore tmp" >>README.md && git st && git add-all && git ci 'Update' && git st && git lg
git rs 1 && git st && git rst README.md && git au && git commit-amend
git co -b develop && git co master && git lga

echoStep "Initialize fork repository"
mkdir -p "$FORK" && cd "$FORK" && git cmd init && git cmd remote add origin "$MAIN" && git f && git branch-checkout-default
git branch-checkout origin/develop && git branch-all && git log-all

echoStep "Initialize submodule"
mkdir -p "$MODULE" && cd "$MODULE" && git cmd init && echo "Tooling" >README.md && git add-all && git ci "Tooling initial commit" && git lg

echoStep "Initialize other submodule"
mkdir -p "$MODULE_OTHER" && cd "$MODULE_OTHER" && git cmd init && echo "Security" >README.md && git add-all && git ci "Security initial commit" && git lg

echoStep "Add the module and create branch develop to main repository"
cd "$MAIN" && git cmd submodule add -- "$MODULE" tooling && git cmd submodule add -- "$MODULE_OTHER" security && git s && git ci 'Add submodules' && git lga

echoStep "Clone a local repository"
git clones "$FORK" "$LOCAL" && cd "$LOCAL" && git upstream "$MAIN" && git fetch-upstream && git brn "feature_login" && git bra && git lga
git pull upstream master && git lga && showRepoFiles && git submodule-update && showRepoFiles

echoStep "Add commit in Tooling submodule"
cd "$MODULE" && echo "Some tool" >|tool.sh && git aa && git ci 'Add tool' && git lga

echoStep "Play with submodules in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git aa && git ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git s && git df && git submodule-update && git s && git submodule-reset security && git s

echoStep "Play more with submodules in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git aa && git ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git s && git df && git submodule-update security && git s && git submodule-reset && git s

echoStep "Upgrade submodules with changes in local repository"
cd "$LOCAL" && cd tooling && echo "something" >|some_file && git aa && git ci 'Add some file'
cd "$LOCAL" && echo 'something' >>security/README.md
git s && git df && git submodule-upgrade security && git submodule-upgrade && git s && showRepoFiles && git df && git lga

echoStep "Clean upgrade of submodules in local repository"
cd "$LOCAL" && git submodule-reset && git s && git submodule-upgrade && git s && git df && git add-update && git ci "Update submodules" && git lga

echoStep "Play with logs"
git log-local-default-origin && git log-local-default-upstream

echoStep "Play with diffs"
git dfsdlu && git dfdlu && git dfsdl && git dfdl

echoStep "Add and reset commits"
echo 'info' >info.txt && git aa && git ci 'Add info' && echo 'data' >data.txt && git aa && git ci 'Add data' && git lga
git reset-commit-last 2 && git s && git reset-repo && git s && git aa && git ci 'Add info and data' && git s && git lga
git remove-commit-last 1 && git lga

# Clean folder
rm -rf "$TMPDIR"

trap - EXIT
