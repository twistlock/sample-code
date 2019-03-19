FROM ubuntu:16.04
LABEL MAINTAINER="Matthew Barker, matthew@twistlock.com" 

LABEL version="1.01"
LABEL security="bad"
LABEL purpose="Twistlock Fargate image for reverse shell usage in demo"

# update and install *traditional* netcat and curl 
RUN apt-get update
RUN apt-get remove -y netcat-openbsd && apt-get install -y netcat-traditional
RUN apt-get install -y curl


