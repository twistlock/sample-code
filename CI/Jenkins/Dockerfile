FROM alpine:3.9
LABEL maintainer="Matthew Barker, security is my responsibiity!"

# update and upgrade packages in alpine 
RUN apk update && apk upgrade 

# install node
RUN apk add --update nodejs npm
RUN npm install -g tough-cookie

# Create a group and user and make it the default user for the container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Add a simple health check cmd
HEALTHCHECK CMD ls /etc/ 

