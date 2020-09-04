#! /bin/bash

# https://github.com/git/git/blob/v2.26.0/Documentation/gittutorial.txt
function setup_gitbash() {
  local ERROR=$SETUP_ERROR_STOP
  local git_path="$APPS_ROOT/PortableApps/PortableGit"

  for file in bash.cmd mintty.cmd; do
    [[ -f "$HOME/$file" ]] || cp -vf "$SETUP_TOOLS_ROOT/gitbash/$file" "$HOME/"
  done

  # Install Git for Windows
  if [[ ! -f "$git_path/bin/git.exe" ]]; then
    download_tarball -e -d "$git_path" "https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/PortableGit-2.28.0-64-bit.7z.exe"
  fi
  [[ ! -f "$git_path/bin/git.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Install wget
  if [[ ! -f "$git_path/usr/bin/wget.exe" ]]; then
    echoColor 36 "Adding wget..."
    download_tarball -o "$git_path/usr/bin/wget.exe" "https://eternallybored.org/misc/wget/1.20.3/64/wget.exe"
    [[ $? -ne 0 ]] && echo "Unable to retrieve wget" && return $ERROR
  fi

  # Install curl, rsync
  local extra_tools=(
    'curl:curl-7.69.1-1-x86_64.pkg.tar.xz'
    'rsync:rsync-3.1.3-1-x86_64.pkg.tar.xz'
  )
  # Install extra tools from ini
  extra_tools+=($(git config -f "$HOME/.common_env.ini" --get-all gitbash.msystool | tr '\n' ' '))

  local index
  local tool
  for index in $(seq 0 $(expr ${#extra_tools[@]} - 1)); do
    tool=$(basename "$(echo "${extra_tools[$index]}" | cut -d: -f1)" .exe)
    [[ -z "$tool" ]] && continue
    tarball=$(echo "${extra_tools[$index]}" | cut -d: -f2)
    if [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${tool}.exe" ]]; then
      echoColor 36 "Adding ${tool}..."
      download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/$tarball"
      [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${tool}.exe" ]] && echo "Error while installing ${tool}..." && return $ERROR
    fi
  done

  # Add git-bash and git-gui to PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/gitbash/PortableGitLauncher" "$APPS_ROOT/PortableApps/"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git-for-windows.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git-for-windows.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon1.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/msys2-32.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon2.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon3.ico"

  # Enable long path
  [[ "$(powershell -Command "Get-ItemPropertyValue -path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -name LongPathsEnabled")" -ne 1 ]] && cmd //C regedit.exe //S "$WINDOWS_SETUP_TOOLS_ROOT\\gitbash\\settings.reg"

  # Generate ssh keys
  if [[ ! -f "$APPS_ROOT/home/.ssh/id_rsa" ]]; then
    local answer='y'
    echo
    read -rep "Do you want to create rsa 4096 SSH keys (Y/n)?: " -i "$answer" answer
    if [[ -z "$answer" ]] || [[ "$answer" =~ ^[yY]$ ]]; then
      ssh-keygen -t rsa -b 4096
      echo -e "\nYou can now deploy your public SSH key with the following command:\n\tssh-copy-id login@remote_machine\n"
      # The input reading does not work well for password
      # answer=1
      # while [ -n "$answer" ]; do
      #   echo -ne "\nType a remote machine where to deploy your public SSH key (or leave empty to stop):"
      #   read -r answer
      #   [ -n "$answer" ] && ssh-copy-id $answer
      # done
    fi
  fi

  return 0
}
