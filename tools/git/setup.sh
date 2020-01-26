#! /bin/sh

function setup_git() {
  for file in .gitconfig bash.cmd mintty.cmd; do
    test -f "$HOME/$file" || cp -vf "$SETUP_TOOLS_ROOT/git/$file" "$HOME/"
  done
  test -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/wget.exe" || cp -vf "$APPS_ROOT/PortableApps/PortableGit/mingw64/bin/wget.exe" "$APPS_ROOT/PortableApps/PortableGit/usr/bin/"
}
