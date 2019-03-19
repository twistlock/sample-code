# Ubuntu with traditional netcat and curl
FROM ubuntu:16.04
LABEL MAINTAINER="Matthew Barker, matthew@twistlock.com"
LABEL version="1.01"
LABEL purpose="Provide easy way to reverse shell for Twistlock FARGATE Demo"

# update and install traditional netcat and curl 
RUN apt-get update
RUN apt-get remove -y netcat-openbsd && apt-get install -y netcat-traditional
RUN apt-get install -y curl

