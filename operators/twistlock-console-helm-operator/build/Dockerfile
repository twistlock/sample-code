FROM quay.io/operator-framework/helm-operator:latest

MAINTAINER Gunjan Patel gpatel@paloaltonetworks.com

### Required OpenShift Labels
LABEL name="prisma-cloud-compute-operator" \
      vendor="Palo Alto Networks" \
      version="1.0.0" \
      release="1.0" \
      summary="This is an operator for Prisma Cloud Compute (Twistlock) Console ." \
      description="This operator will deploy Prisma Cloud Compute (Twistlock) Console."

COPY licenses /licenses

COPY helm-charts ${HOME}/helm-charts/
COPY ./watches.yaml ${HOME}/watches.yaml