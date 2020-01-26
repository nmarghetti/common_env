#! /bin/sh

# Check documentation https://docs.python.org/3/using/windows.html#installing-without-ui

function check_python() {
  test $(ls -1 "$python_path" 2>/dev/null | wc -l) -eq 0 && return 1
  test $(ls -1 "$python_path/Scripts" 2>/dev/null | wc -l) -eq 0 && return 1
  return 0
}

function setup_python() {
  python_path="PortableApps/CommonFiles/python3.8.1"
  python_winpath="$(echo $WIN_APPS_ROOT/$python_path | tr '/' '\\')"
  python_path="$APPS_ROOT/$python_path"
  export PATH=$python_path:$PATH
  
  if test check_python; then
    mkdir -vp "$python_path"
    exe=python-3.8.1-amd64.exe
    if [ ! -f $exe ]; then
      wget --progress=bar:force https://www.python.org/ftp/python/3.8.1/$exe
      test $? -ne 0 && echo "Error, unable to retrieve the executable." && return 1
    fi
    # First uninstall as otherwise it might be complicated to install it
    test check_python && echo "First uninstall python or upgrade it if already installed" && \
    cmd //c $exe /uninstall /quiet /passive TargetDir="$python_winpath" AssociateFiles=0 Shortcuts=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_tcltk=0 Include_test=0 SimpleInstall=1
    test check_python && echo "Then uninstall it" && \
    cmd //c $exe /uninstall /quiet /passive TargetDir="$python_winpath" AssociateFiles=0 Shortcuts=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_tcltk=0 Include_test=0 SimpleInstall=1
    test check_python && echo "Now install it" && \
    cmd //c $exe /quiet /passive TargetDir="$python_winpath" AssociateFiles=0 Shortcuts=0 Include_launcher=0 InstallLauncherAllUsers=0 Include_tcltk=0 Include_test=0 SimpleInstall=1
    test check_python && echo "Error, unable to install python." && rm -rf "$python_path" && return 1
    rm -f $exe
  fi
  if [ $("$SETUP_TOOLS_ROOT/bash/bin/pythonenv.sh" list | wc -l) -eq 0 ]; then
    "$SETUP_TOOLS_ROOT/bash/bin/pythonenv.sh" create || (echo "Error, unable to set python virtual env." && return 1)
  fi
}
