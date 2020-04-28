#! /bin/sh

# Disable SSL certificate verification failure
npm config set strict-ssl false
yarn config set strict-ssl false -g
pip config set global.trusted_host pypi.org
NODE_TLS_REJECT_UNAUTHORIZED=0
echo insecure >~/.curlrc
# curl -k
# wget --no-check-certificate
