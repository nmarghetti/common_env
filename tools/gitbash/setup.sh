#! /bin/bash

# https://github.com/git/git/blob/v2.26.0/Documentation/gittutorial.txt
function setup_gitbash() {
  local ERROR=$SETUP_ERROR_STOP

  for file in bash.cmd mintty.cmd; do
    test -f "$HOME/$file" || cp -vf "$SETUP_TOOLS_ROOT/gitbash/$file" "$HOME/"
  done

  local tarball
  git_path="$APPS_ROOT/PortableApps/PortableGit"

  # Install wget
  if [ ! -f "$git_path/usr/bin/wget.exe" ]; then
    curl -k --progress-bar -o "$git_path/usr/bin/wget.exe" "https://eternallybored.org/misc/wget/1.20.3/64/wget.exe"
    [ $? -ne 0 ] && echo "Unable to retrieve wget" && return $ERROR
  fi

  # Install Git for Windows
  if [ ! -f "$git_path/bin/git.exe" ]; then
    tarball=PortableGit-2.26.0-64-bit.7z.exe
    tarball_path="$APPS_ROOT/PortableApps/$tarball"
    if [ ! -f $tarball_path ]; then
      wget --progress=bar:force -O "$tarball_path" https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/$tarball
      test $? -ne 0 && echo "Error, unable to retrieve the archive." && return $ERROR
    fi
    "$tarball_path"
    ret=$?
    [ $ret -ne 0 ] && echo "Error while installing Git for Windows ($ret)" && return $ret
    rm -f "$tarball_path"
  fi

  [ ! -f "$git_path/bin/git.exe" ] && echo "Failed to install git bash" && return $ERROR

  # Install rsync, tree
  local extra_tools=('rsync:rsync-3.1.3-1-x86_64.pkg.tar.xz' 'tree:tree-1.8.0-1-x86_64.pkg.tar.xz')
  local index
  local tool
  for index in $(seq 0 $(expr ${#extra_tools[@]} - 1)); do
    tool=$(echo "${extra_tools[$index]}" | cut -d: -f1)
    tarball=$(echo "${extra_tools[$index]}" | cut -d: -f2)
    if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${tool}.exe" ]; then
      echoColor 36 "Adding ${tool}..."
      output_tar="$APPS_ROOT/PortableApps/PortableGit/"
      if [ ! -f "$output_tar/$tarball" ]; then
        wget --progress=bar:force -O "$output_tar/$tarball" http://repo.msys2.org/msys/x86_64/$tarball
        test $? -ne 0 && echo "Error, unable to retrieve the archive." && return $ERROR
      fi
      exec 3>&1
      (cd "$output_tar" && tar -vxJf "$tarball" | awk 'BEGIN {ORS="."} {print "."}' >&3)
      echo
      rm -f "$output_tar/$tarball"
      [ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${tool}.exe" ] && echo "Error while installing ${tool}..." && return $ERROR
    fi
  done

  # Add git-bash and git-gui to PortableApps menu
  if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/rsync.exe" ]; then
    echo "Unable to put Git-bash nor Git-GUI in PortableApps menu as rsync is not available"
  else
    rsync -au "$SETUP_TOOLS_ROOT/gitbash/PortableGitLauncher" "$APPS_ROOT/PortableApps/"
    if [ ! -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico" ]; then
      wget --progress=bar:force -O "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico" https://raw.githubusercontent.com/git-for-windows/git-sdk-64/master/mingw64/share/git/git-for-windows.ico
      if [ $? -ne 0 ]; then
        rm -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico"
        echo "Warning, unable to retrieve icon for git bash..."
      fi
    fi
    if [ -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico" ]; then
      for index in $(seq 3); do
        (cd "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo" && [ ! -f "appicon${index}.ico" ] && cp "appicon.ico" "appicon${index}.ico")
      done
    fi
  fi

  return 0
}
