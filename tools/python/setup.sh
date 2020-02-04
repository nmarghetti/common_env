#! /bin/sh

# Check documentation https://docs.python.org/3/using/windows.html#installing-without-ui

function check_python() {
  test ! -f "$python_path/python.exe" && echo "No python installed" >&2 && return 1
  test ! -f "$python_path/Scripts/pip.exe" && echo "No pip installed" >&2 && return 1
  return 0
}

function setup_python() {
  local python_path="PortableApps/CommonFiles/python"
  local python_winpath="$(echo $WIN_APPS_ROOT/$python_path | tr '/' '\\')"
  python_path="$APPS_ROOT/$python_path"
  export PATH=$python_path:$PATH
  
  if ! check_python 2>/dev/null; then
    mkdir -vp "$python_path"
    local exe=python-3.8.1-amd64.exe
    if [ ! -f $exe ]; then
      wget --progress=bar:force https://www.python.org/ftp/python/3.8.1/$exe
      test $? -ne 0 && echo "Error, unable to retrieve the executable." && return 1
    fi
    # Let 9 tries to the user to install it
    ! check_python && for i in $(seq 9); do
      echo "$i/9 If it does not just ask to install, try first to uninstall. If it fails, then repair, then uninstall, then you will be able to install." && \
      cmd //c $exe /quiet /passive TargetDir="$python_winpath" Include_pip=1 AssociateFiles=0 Shortcuts=0 Include_launcher=0 \
      InstallLauncherAllUsers=0 Include_tcltk=0 Include_test=0 SimpleInstall=1 \
      SimpleInstallDescription="It will install python and pip."
      # if the user click on cancel
      test $? -eq 66 && break
      check_python && break
    done
    check_python 2>/dev/null && rm -f $exe
  fi
  ! check_python 2>/dev/null && return 1
  if [ $("$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" list | wc -l) -eq 0 ]; then
    local version="$("$python_path/python" --version | cut -d' ' -f2 | tr -d '[[:space:]]')"
    "$SETUP_TOOLS_ROOT/bash/bin/pythonvenv.sh" create "$version" || (echo "Error, unable to set python virtual env." && return 1)
    sed -ri -e "s#$(echo "$WINDOWS_APPS_ROOT" | sed -re "s#\\\\#\\\\\\\\#")\\\\PortableApps\\\\CommonFiles\\\\python#$APPS_ROOT/PortableApps/CommonFiles/python#" "$HOME/.venv/$version/pyvenv.cfg"
    sed -ri -e "s#$(echo "$WINDOWS_APPS_ROOT" | sed -re "s#\\\\#\\\\\\\\#")\\\\home\\\\.venv\\\\$version#$APPS_ROOT/home/.venv/$version#" "$HOME/.venv/$version/Scripts/activate"
  fi
}
