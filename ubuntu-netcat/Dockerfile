FROM ubuntu:16.04
MAINTAINER Matthew Barker 

LABEL version="1.01"
LABEL security="bad"

# update and install *traditional* netcat and curl 
RUN apt-get update
RUN apt-get remove -y netcat-openbsd && apt-get install -y netcat-traditional
RUN apt-get install -y curl

