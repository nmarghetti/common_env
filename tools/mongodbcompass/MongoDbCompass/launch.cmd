@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\MongoDbCompass"
START /B mongodb-compass.exe

