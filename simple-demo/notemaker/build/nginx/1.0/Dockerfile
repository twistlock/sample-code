FROM nginx:1.18-alpine
LABEL maintainer="Matt Barker"
LABEL application="notemaker"
LABEL tier="web"
LABEL version="1.0"
LABEL baseImage="nginx:1.18-alpine"
RUN chmod +w /etc/nginx/conf.d/default.conf 
COPY web-service.conf /etc/nginx/conf.d/default.conf

