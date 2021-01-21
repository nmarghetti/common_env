@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\elastic\elasticsearch\bin"
echo Starting Elasticsearch, if everything goes well you should be able to access this:
echo http://localhost:9200/

START /B elasticsearch.bat
