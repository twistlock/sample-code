#!/bin/bash
# This script requires that you have kubectl authenticated against your
# cluster before you begin. In essence, this script will use kubectl to
# find all of the images within a particular namespace, and create a
# collection that is limited to the images returned from that kubectl
# command. This can be helpful if you are looking to limit a users view
#  to just the images that are relevant to a particular namespace.

NAMESPACE=default
COLLECTION_NAME=mycollection
COLLECTION_COLOR='#ff0000'
TL_ADMIN_USER='admin'
TL_ADMIN_PW='secretpass'
TL_CONSOLE_HTTPS="https://twistlock.example.com"

function get_images_in_namespace {
  kubectl get pods -n $NAMESPACE -o jsonpath="{..image}" |\
  tr -s '[[:space:]]' '\n' |\
  sort |\
  uniq -c |\
  awk '{print $2}'
}

IMAGES=$(get_images_in_namespace)

function create_collection {
IMAGES_STRING=$(printf -- ", \"%s\"" ${IMAGES[*]} | cut -d ',' -f 2-)
curl -s -k -u $TL_ADMIN_USER:$TL_ADMIN_PW \
  -X POST \
  -H 'Content-Type: application/json' \
  -d "{ \
  \"name\":\"${COLLECTION_NAME}\", \
  \"color\":\"${COLLECTION_COLOR}\", \
  \"description\": \
  \"A collection for images within ${NAMESPACE}\", \
  \"images\":[${IMAGES_STRING}], \
  \"hosts\":[\"*\"], \
  \"containers\":[\"*\"], \
  \"labels\":[\"*\"]}" \
  "${TL_CONSOLE_HTTPS}/api/v1/collections"
}

create_collection
