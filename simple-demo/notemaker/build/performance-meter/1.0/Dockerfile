FROM alpine:3.9 

LABEL maintainer="Matt Barker"
LABEL application="notemaker" 
LABEL tier="database" 
LABEL appVersion="1.0"
LABEL baseImage="alpine:3.9"

RUN apk add --update curl && rm -rf /var/cache/apk/* 

RUN apk add mongodb-tools 

COPY collectStats.sh collectStats.sh

# collect stats every 300 seconds (5 minutes)
ENTRYPOINT ["./collectStats.sh"]
CMD ["300"]

LABEL patch="1.1.1.1.1.1.1.1.1.1.1"

