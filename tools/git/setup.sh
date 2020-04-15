#! /bin/bash

# https://code.visualstudio.com/docs/remote/troubleshooting#_resolving-git-line-ending-issues-in-wsl-resulting-in-many-modified-files
function setup_git() {
  # Create template .gitconfig if not there yet
  if [ ! -f "$HOME/.gitconfig" ]; then
    echo "Create $HOME/.gitconfig"
    cat >"$HOME/.gitconfig" <<EOM
[user]
  name = "user" # put your username
  email = "mail" # put yor email


# BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
# END - GENERATED CONTENT, DO NOT EDIT !!!

# Custom settings
[core]
  autocrlf = input
EOM
    if [ "$SETUP_SILENT" -eq 0 ]; then
      local current_user=$USER
      if [ -z "$current_user" ]; then
        current_user=$USERNAME
      fi
      echo -n "Please enter your git user name ($current_user): "
      local user
      read -r user
      if [ -z "$user" ]; then
        user=$current_user
      fi
      echo -n "Please enter your git user email address: "
      local mail
      read -r mail
      git config --global user.name "$user"
      git config --global user.email "$mail"
    fi
  fi

  # Add content into .gitconfig
  local gitconfig="$(cat "$HOME/.gitconfig")"
  echo "$gitconfig" | awk -f "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v replace_append=1 -v content_file="$SETUP_TOOLS_ROOT/git/.gitconfig" >|"$HOME/.gitconfig"
}
