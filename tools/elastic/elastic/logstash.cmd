@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\elastic\logstash\bin"
echo Starting logstash with stdin
echo Ensure you have started Elasticsearch ^(http://localhost:9200/^)
echo When the server will be ready, you can write anything in there it will be sent to logstash
echo You can run Kibana to discover it after a few minutes through this:
echo
logstash.bat -f ..\..\logstash_sample.conf

