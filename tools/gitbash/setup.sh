#! /usr/bin/env bash

# https://github.com/git/git/blob/v2.26.0/Documentation/gittutorial.txt
function setup_gitbash() {
  local ERROR=$SETUP_ERROR_STOP
  local git_path="$APPS_ROOT/PortableApps/PortableGit"

  # Ensure to create Desktop folder
  mkdir -p "$HOME/Desktop"

  for file in bash.cmd; do
    [[ ! -f "$HOME/$file" || "$SETUP_TOOLS_ROOT/gitbash/$file" -nt "$HOME/$file" ]] && cp -vf "$SETUP_TOOLS_ROOT/gitbash/$file" "$HOME/"
  done

  # https://stackoverflow.com/questions/25730041/updating-file-permissions-with-git-bash-on-windows-7
  # To allow to have file permission and make chmod working, replace in /etc/fstab
  # none / cygdrive binary,posix=0,noacl,user 0 0
  # none /tmp usertemp binary,posix=0,noacl 0 0
  # by
  # none / cygdrive binary,posix=0,user 0 0
  # none /tmp usertemp binary,posix=0 0 0

  # Install Git for Windows
  if [[ ! -f "$git_path/bin/git.exe" ]]; then
    download_tarball -e -d "$git_path" "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/PortableGit-2.43.0-64-bit.7z.exe"
  fi
  [[ ! -f "$git_path/bin/git.exe" ]] && echo "Binary file not installed" && return "$ERROR"

  # Handle symlink:
  # https://github.com/git-for-windows/git/wiki/Symbolic-Links
  # https://www.joshkel.com/2018/01/18/symlinks-in-windows/
  # https://dev.to/hakonhagland/handling-of-symlinks-on-windows-perl-msys2-cygwin-52h3

  # Add custom ln to allow to have ln working with symlinks
  # Unfortunately it does not seem to work with executable files
  # [[ -f "/usr/bin/ln.exe" ]] && mv "/usr/bin/ln.exe" "/usr/bin/lnmsys.exe"
  # cmp --silent "/usr/bin/ln" "$SETUP_TOOLS_ROOT/shell/msys/ln" || cp -vf "$SETUP_TOOLS_ROOT/shell/msys/ln" "/usr/bin/ln"
  # Remove previous installation
  # if [[ -f "/usr/bin/lnmsys.exe" ]]; then
  #   rm -f /usr/bin/ln
  #   mv /usr/bin/lnmsys.exe /usr/bin/ln.exe
  # fi

  # Allow Msys2 to use the proper Home: https://sourceforge.net/p/msys2/tickets/111/?page=2
  # Replace db_home: env windows cygwin desc
  sed -i -re "s#^db_home:.*#db_home: $(echo "$HOME" | sed -re 's/ /%_/g')#" /etc/nsswitch.conf

  # Generate ssh keys
  if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
    echo -e "\nYou can now deploy your public SSH key with the following command:\n\tssh-copy-id login@remote_machine\n"
  fi

  # Update certificates
  "$SETUP_TOOLS_ROOT"/helper/update_certificate.sh

  # Enable long path
  [[ "$(powershell -Command "Get-ItemPropertyValue -path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -name LongPathsEnabled")" -ne 1 ]] && cmd //C regedit.exe //S "$WINDOWS_SETUP_TOOLS_ROOT\\gitbash\\settings.reg"

  # # Install wget
  # if [[ ! -f "$git_path/usr/bin/wget.exe" ]]; then
  #   echoColor 36 "Adding wget..."
  #   download_tarball -o "$git_path/usr/bin/wget.exe" "https://eternallybored.org/misc/wget/1.20.3/64/wget.exe"
  #   [[ $? -ne 0 ]] && echo "Unable to retrieve wget" && return $ERROR
  # fi

  # Intall zstd
  local zstd_version="1.5.6"
  if [ ! -f "$git_path/usr/bin/zstd.exe" ]; then
    echoColor 36 "Adding zstd..."
    if [ ! -f "$APPS_ROOT/PortableApps/PortableGit/zstd/zstd.exe" ]; then
      if ! download_tarball -e -d "$APPS_ROOT/PortableApps/PortableGit/zstd" -m "zstd-v${zstd_version}-win64" "https://github.com/facebook/zstd/releases/download/v${zstd_version}/zstd-v${zstd_version}-win64.zip"; then
        echo "Unable to retrieve zstd" && return "$ERROR"
      fi
    fi
    zstd_version="1.5.6-1-x86_64"
    download_tarball -o "$APPS_ROOT/PortableApps/PortableGit/libzstd.pkg.tar.zst" "http://repo.msys2.org/msys/x86_64/libzstd-${zstd_version}.pkg.tar.zst"
    download_tarball -o "$APPS_ROOT/PortableApps/PortableGit/zstd.pkg.tar.zst" "http://repo.msys2.org/msys/x86_64/zstd-${zstd_version}.pkg.tar.zst"
    "$APPS_ROOT/PortableApps/PortableGit/zstd/zstd.exe" -d "$APPS_ROOT/PortableApps/PortableGit/libzstd.pkg.tar.zst"
    "$APPS_ROOT/PortableApps/PortableGit/zstd/zstd.exe" -d "$APPS_ROOT/PortableApps/PortableGit/zstd.pkg.tar.zst"
    tar -xf "$APPS_ROOT/PortableApps/PortableGit/libzstd.pkg.tar" -C "$APPS_ROOT/PortableApps/PortableGit/"
    tar -xf "$APPS_ROOT/PortableApps/PortableGit/zstd.pkg.tar" -C "$APPS_ROOT/PortableApps/PortableGit/"
    rm -rf "$APPS_ROOT"/PortableApps/PortableGit/libzstd* "$APPS_ROOT"/PortableApps/PortableGit/zstd*
  fi

  # Install rsync, zstd
  local extra_tools=(
    'msys-xxhash-0.dll:libxxhash-0.8.1-1-x86_64.pkg.tar.zst'
    'rsync.exe:rsync-3.3.0-1-x86_64.pkg.tar.zst'
  )
  # Install extra tools from ini
  extra_tools+=($(git --no-pager config -f "$HOME/.common_env.ini" --get-all gitbash.msystool 2>/dev/null | tr '\n' ' '))

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
      [[ ! -f "$APPS_ROOT/PortableApps/PortableGit/usr/bin/${toolfile}" ]] && echo "Error while installing ${tool}..." && return "$ERROR"
    fi
  done

  # Add git-bash and git-gui to PortableApps menu
  rsync -vau "$SETUP_TOOLS_ROOT/gitbash/PortableGitLauncher" "$APPS_ROOT/PortableApps/"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git-for-windows.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git-for-windows.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon1.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/msys2-32.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon2.ico"
  rsync -au "$APPS_ROOT/PortableApps/PortableGit/usr/share/git/git.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon3.ico"
  [[ ! -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon4.ico" ]] &&
    download_tarball -o "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon4.ico" "https://raw.githubusercontent.com/zsh-users/zsh/master/Src/zsh.ico"
  [[ ! -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon5.ico" ]] &&
    download_tarball -o "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon5.ico" "https://icon-icons.com/downloadimage.php?id=131831&root=2148/ICO/128/&file=tmux_icon_131831.ico"
  [[ ! -f "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon6.ico" ]] &&
    cp -vf "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon5.ico" "$APPS_ROOT/PortableApps/PortableGitLauncher/App/AppInfo/appicon6.ico"

  return 0
}
