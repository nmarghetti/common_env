#! /bin/bash

ipconfig.exe /allcompartments /all | grep -iE 'cisco anyconnect' -A13 | grep -iE 'ipv4' | cut -d':' -f2 | cut -d'(' -f1 | tr -d '[:space:]'
