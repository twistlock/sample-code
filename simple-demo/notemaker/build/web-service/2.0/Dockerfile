FROM node:alpine
LABEL maintainer="Matt B"
LABEL application="NoteMaker"
LABEL tier="web"
LABEL version="2.0"
LABEL baseImage="node:alpine"

COPY . .
RUN npm install

# npm can fix some vulnerabilties
RUN npm audit fix
# add a user
USER node

CMD [ "node", "index.js" ]

LABEL patch="2"
