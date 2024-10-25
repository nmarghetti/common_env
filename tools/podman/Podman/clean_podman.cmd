@echo off
setlocal enabledelayedexpansion

set found=0
for /f "tokens=*" %%i in ('podman machine list --format "{{.Name}}"') do (
    if "%%i"=="podman-machine-portable" (
        set found=1
    )
)
echo No remaining podman-machine-portable to clean
if !found! equ 0 (
  goto :end
)

@REM for /f "tokens=*" %%i in ('podman machine list --format "{{.Name}}"') do (
@REM     set machine=%%i
@REM     REM Check the running status of each machine
@REM     for /f "tokens=*" %%j in ('podman machine inspect %%i --format "{{.State}}"') do (
@REM         set status=%%j
@REM         echo Machine: !machine!, Status: !status!
@REM     )
@REM )

@REM Remove all podman machines
@REM podman machine reset -f

podman machine rm -f podman-machine-portable
podman system connection remove podman-machine-portable
podman system connection remove podman-machine-portable--root

@REM @REM Remove any system connection left if any
@REM for /f "tokens=*" %%k in ('podman system connection list --format "{{.Name}}"') do (
@REM     set connection=%%k
@REM     if connection EQU "podman-machine-portable" or co
@REM     podman system connection remove !connection!
@REM )

:end
endlocal
exit 0
