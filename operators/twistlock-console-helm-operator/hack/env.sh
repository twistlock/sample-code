#!/bin/sh

# Copyright 2019 ArgoCD Operator Developers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# General vars
export OPERATOR_NAME=${OPERATOR_NAME:-"prisma-cloud-compute-console-operator"}
export OPERATOR_IMG_NAME=${OPERATOR_IMG_NAME:-"compute-console-operator"}
export OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE:-"twistlock"}
export OPERATOR_VERSION=${OPERATOR_VERSION:-"latest"}
export OPERATOR_BUILD_DIR=${OPERATOR_BUILD_DIR:-"build"}

# Container image vars
export OPERATOR_IMAGE_BUILDER=${OPERATOR_IMAGE_BUILDER:-"docker"}
export OPERATOR_IMAGE_REPO=${OPERATOR_IMAGE_REPO:-"prismacloud/${OPERATOR_IMG_NAME}"}
export OPERATOR_IMAGE_TAG=${OPERATOR_IMAGE_TAG:-"1.0.0"}
export OPERATOR_IMAGE=${OPERATOR_IMAGE:-"${OPERATOR_IMAGE_REPO}:${OPERATOR_IMAGE_TAG}"}

# Operator bundle vars
export OPERATOR_BUNDLE_DIR=${OPERATOR_BUNDLE_DIR:-"bundle"}
export OPERATOR_BUNDLE_BUILD_DIR=${OPERATOR_BUNDLE_BUILD_DIR:-"${OPERATOR_BUILD_DIR}/_output/bundle"}
export OPERATOR_BUNDLE_MANIFEST_DIR=${OPERATOR_BUNDLE_MANIFEST_DIR:-"olm-catalog/${OPERATOR_NAME}"}
export OPERATOR_BUNDLE_IMAGE_NAME=${OPERATOR_BUNDLE_IMAGE_NAME:-"${OPERATOR_NAME}-registry"}
export OPERATOR_BUNDLE_IMAGE_REPO=${OPERATOR_BUNDLE_IMAGE_REPO:-"prismacloud/${OPERATOR_IMG_NAME}"}
export OPERATOR_BUNDLE_IMAGE_TAG=${OPERATOR_BUNDLE_IMAGE_TAG:-"1.0.0"}
export OPERATOR_BUNDLE_IMAGE=${OPERATOR_BUNDLE_IMAGE:-"${OPERATOR_BUNDLE_IMAGE_REPO}:${OPERATOR_BUNDLE_IMAGE_TAG}"}

# Ensure go module support is enabled
export GO111MODULE=on
