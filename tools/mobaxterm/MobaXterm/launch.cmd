@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\MobaXterm"
REM Run from previous installation
if exist MobaXterm_Personal_20.2.exe (
  START /B MobaXterm_Personal_20.2.exe
) else (
  START /B MobaXterm_Personal.exe
)

