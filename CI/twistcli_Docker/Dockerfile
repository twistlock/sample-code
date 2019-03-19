FROM alpine 
LABEL MAINTAINER="Matthew Barker, matthew@twistlock.com" 

ARG tl-version 
LABEL twistlock-version="$tl-version"
LABEL purpose="Twistlock Image Scan Utility"

RUN apk add curl docker

COPY twistcli /usr/local/bin/twistcli





