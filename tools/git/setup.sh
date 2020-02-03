#! /bin/sh

function setup_git() {
  for file in bash.cmd mintty.cmd; do
    test -f "$HOME/$file" || cp -vf "$SETUP_TOOLS_ROOT/git/$file" "$HOME/"
  done
  test -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/wget.exe" || cp -vf "$APPS_ROOT/PortableApps/PortableGit/mingw64/bin/wget.exe" "$APPS_ROOT/PortableApps/PortableGit/usr/bin/"

  # Create template .gitconfig if not there yet
  if [ ! -f "$HOME/.gitconfig" ]; then
    echo "Create $HOME/.gitconfig"
    cat > "$HOME/.gitconfig" << EOM
[user]
  name = "user" # put your username
  email = "mail" # put yor email

# Custom settings

# BEGIN - GENERATED CONTENT, DO NOT EDIT !!!
# END - GENERATED CONTENT, DO NOT EDIT !!!

# Custom settings
EOM
  fi

  # Add content into .gitconfig
  local gitconfig="$(cat "$HOME/.gitconfig")"
  echo "$gitconfig" | "$SETUP_TOOLS_ROOT/bash/bin/generated_content.awk" -v action=replace -v replace_append=1 -v content_file="$SETUP_TOOLS_ROOT/git/.gitconfig" >| "$HOME/.gitconfig"
}
