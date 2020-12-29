#! /usr/bin/env bash

# https://github.com/git/git/blob/v2.26.0/Documentation/gittutorial.txt
function setup_gitbash() {
  local ERROR=$SETUP_ERROR_STOP
  local git_path="$APPS_ROOT/PortableApps/PortableGit"

  for file in bash.cmd mintty.cmd; do
    [[ -f "$HOME/$file" ]] || cp -vf "$SETUP_TOOLS_ROOT/gitbash/$file" "$HOME/"
  done

  # Install Git for Windows
  if [[ ! -f "$git_path/bin/git.exe" ]]; then
    download_tarball -e -d "$git_path" "https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.3/PortableGit-2.29.2.3-64-bit.7z.exe"
  fi
  [[ ! -f "$git_path/bin/git.exe" ]] && echo "Binary file not installed" && return $ERROR

  # Add custom ln to allow to have ln working with symlinks
  [[ -f "/usr/bin/ln.exe" ]] && mv "/usr/bin/ln.exe" "/usr/bin/lnmsys.exe"
  cmp --silent "/usr/bin/ln" "$SETUP_TOOLS_ROOT/shell/msys/ln" || cp -vf "$SETUP_TOOLS_ROOT/shell/msys/ln" "/usr/bin/ln"

  # Allow Msys2 to use the proper Home: https://sourceforge.net/p/msys2/tickets/111/?page=2
  # Replace db_home: env windows cygwin desc
  sed -i -re "s#^db_home:.*#db_home: $(echo "$HOME" | sed -re 's/ /%_/g')#" /etc/nsswitch.conf

  # Install ca certificate if provided
  local cacert=$(git config -f "$APPS_ROOT/setup.ini" --get install.cacert 2>/dev/null | sed -re "s#%APPS_ROOT%#$APPS_ROOT#g")
  if [[ -f "$cacert" ]]; then
    local bundle
    for bundle in /mingw64/ssl/certs/ca-bundle.crt /usr/ssl/certs/ca-bundle.crt; do
      if [[ ! -f "$bundle" ]] || ! cmp --silent "$cacert" "$bundle"; then
        [[ -f "$bundle" && ! -f "$bundle.backup" ]] && mv "$bundle" "$bundle.backup"
        cp -vf "$cacert" "$bundle"
      fi
    done
  fi

  # Install wget
  if [[ ! -f "$git_path/usr/bin/wget.exe" ]]; then
    echoColor 36 "Adding wget..."
    download_tarball -o "$git_path/usr/bin/wget.exe" "https://eternallybored.org/misc/wget/1.20.3/64/wget.exe"
    [[ $? -ne 0 ]] && echo "Unable to retrieve wget" && return $ERROR
  fi

  # Install rsync, zstd
  local extra_tools=(
    'msys-zstd-1.dll:libzstd-1.4.5-2-x86_64.pkg.tar.xz'
    'zstd.exe:zstd-1.4.5-2-x86_64.pkg.tar.xz'
    'msys-xxhash-0.8.0.dll:libxxhash-0.8.0-1-x86_64.pkg.tar.zst'
    'rsync.exe:rsync-3.2.2-2-x86_64.pkg.tar.zst'
  )
  # Install extra tools from ini
  extra_tools+=($(git config -f "$HOME/.common_env.ini" --get-all gitbash.msystool 2>/dev/null | tr '\n' ' '))

  local index
  local tool
  local toolfile
  for index in $(seq 0 $(expr ${#extra_tools[@]} - 1)); do
    tool=$(basename "$(echo "${extra_tools[$index]}" | cut -d: -f1)" .exe)
    [[ -z "$tool" ]] && continue
    tarball=$(echo "${extra_tools[$index]}" | cut -d: -f2)
    toolfile=$(echo "${extra_tools[$index]}" | cut -d: -f1)
    if [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${toolfile}" ]]; then
      echoColor 36 "Adding ${tool}..."
      download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/" "http://repo.msys2.org/msys/x86_64/$tarball"
      [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${toolfile}" ]] && echo "Error while installing ${tool}..." && return $ERROR
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
  if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
    echo -e "\nYou can now deploy your public SSH key with the following command:\n\tssh-copy-id login@remote_machine\n"
  fi

  return 0
}
