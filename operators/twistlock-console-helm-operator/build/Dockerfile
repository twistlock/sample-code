FROM quay.io/operator-framework/helm-operator:latest

### Required OpenShift Labels
LABEL name="prisma-cloud-compute-operator" \
      vendor="Palo Alto Networks" \
      version="1.0.0" \
      release="1.0" \
      summary="This is an operator for Prisma Cloud Compute (Twistlock) Console ." \
      description="This operator will deploy Prisma Cloud Compute (Twistlock) Console."

RUN mkdir ${HOME}/helm-charts
RUN pwd
RUN ls -la
RUN ls -la  ${HOME}/

COPY ./helm-charts/ ${HOME}/helm-charts/
COPY ./watches.yaml ${HOME}/watches.yaml