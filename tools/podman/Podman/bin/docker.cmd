@echo off

REM Check if podman is installed
where podman >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo "You need to install podman first"
    exit 1
)

REM Check if podman machine is running
for /f "tokens=*" %%i in ('podman machine info --format "{{.Host.MachineState}}"') do set MACHINE_STATE=%%i
if "%MACHINE_STATE%" NEQ "Running" (
    podman machine start podman-machine-portable
)

podman %*
