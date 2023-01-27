@echo off

CMD /C START /WAIT gcloud\bin\gcloud.cmd components install %*

exit 0
