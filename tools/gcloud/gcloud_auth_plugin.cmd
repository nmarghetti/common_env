@echo off

CMD /C START /WAIT gcloud\bin\gcloud.cmd components install gke-gcloud-auth-plugin

exit 0
