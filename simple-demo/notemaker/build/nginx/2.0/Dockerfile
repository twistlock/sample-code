FROM nginx:1.19
LABEL maintainer="Matt Barker"
LABEL application="notemaker"
LABEL tier="web"
LABEL version="2.0"
LABEL baseImage="nginx:1.19"
LABEL patch="2.1"
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.orig
COPY default.conf /etc/nginx/conf.d/default.conf

