#!/bin/sh

HACK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${HACK_DIR}/env.sh

# Build the operator container image
operator-sdk build ${OPERATOR_IMAGE} --image-builder ${OPERATOR_IMAGE_BUILDER}

# Push the operator container image
${OPERATOR_IMAGE_BUILDER} push ${OPERATOR_IMAGE}
