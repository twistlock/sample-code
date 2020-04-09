#!/bin/sh

set -e

HACK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${HACK_DIR}/env.sh

# Create bundle build directory
mkdir -p ${OPERATOR_BUNDLE_BUILD_DIR}

# Copy bundle artifacts
cp -r ${OPERATOR_BUNDLE_DIR}/* ${OPERATOR_BUNDLE_BUILD_DIR}/

# Copy manifests 
mkdir -p ${OPERATOR_BUNDLE_BUILD_DIR}/manifests
cp -r ${OPERATOR_BUNDLE_MANIFEST_DIR} ${OPERATOR_BUNDLE_BUILD_DIR}/manifests/

# Build the bundle registry container image
${OPERATOR_IMAGE_BUILDER} build -t ${OPERATOR_BUNDLE_IMAGE} ${OPERATOR_BUNDLE_BUILD_DIR}

# Push the bundle registry container image
${OPERATOR_IMAGE_BUILDER} push ${OPERATOR_BUNDLE_IMAGE}
