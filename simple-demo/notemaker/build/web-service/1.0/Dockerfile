FROM node:12.0-slim

LABEL maintainer="Matt Barker"
LABEL application="notemaker"
LABEL tier="web"
LABEL version="1.0"
LABEL baseImage="node:12.0-slim"

RUN apt update && apt install -y iputils-ping

COPY . .
RUN npm install
CMD [ "node", "index.js" ]

LABEL patch="2.1.1.1.1"

