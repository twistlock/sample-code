FROM nginx:1.19
LABEL maintainer="Matt Barker"
LABEL application="notemaker"
LABEL tier="web"
LABEL version="2.0"
LABEL baseImage="nginx:1.19"
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.orig
COPY web-service.conf /etc/nginx/conf.d/web-service.conf

