FROM nginx
LABEL maintainer="Matthew Barker"
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.orig
COPY web-service.conf /etc/nginx/conf.d/web-service.conf

