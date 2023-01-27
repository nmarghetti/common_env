@echo off

CMD /C START /WAIT gcloud\bin\gcloud.cmd components update --version %1%

exit 0
