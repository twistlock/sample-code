#!/bin/bash
# This script requires that you have kubectl authenticated against your
# cluster before you begin. In essence, this script will use kubectl to
# find all of the images within a particular namespace, and create a
# collection that is limited to the images returned from that kubectl
# command. This can be helpful if you are looking to limit a users view
# to just the images that are relevant to a particular namespace.
# In the event that a Collection of the same name already exists, the
# old Collection will be overwritten.


# All of these variables can be set as environment variables. All but the
# TL_USER_PW var can be passed as a CLI option. When not defined, the user
# will be prompted for the TL_USER_PW value.
# As mentioned in the usage test, CLI flags will override environment
# variables.
NAMESPACE="${NAMESPACE:-default}"
COLLECTION_NAME="${COLLECTION_NAME:-mycollection}"
COLLECTION_COLOR="${COLLECTION_COLOR:-#ff0000}"
TL_USER="${TL_USER:-$TL_USER}"
TL_USER_PW="${TL_USER_PW:-NONE}"
TL_CONSOLE="${TL_CONSOLE:-NONE}"

usage() {
  local scriptnm="${0##*/}"
  local docstring="Usage:
  ${scriptnm} [ -a TL_CONSOLE ] [ -u TL_USER ] [ -n NAMESPACE ]  
                                [ -N COLLECTION_NAME ] [ -c COLLECTION_COLOR ]\n
  Options:
    -a TL_CONSOLE     the Console URL (eg - https://console.address:8083).
    -u TL_USER     authenticate using this Console user account (default: $TL_USER)
    -n NAMESPACE           query the images in this k8s namespace (default: \"default\" namespace)
    -N COLLECTION_NAME     the name of the new collection (default: mycollection)
    -c COLLECTION_COLOR    the hex code for the collection color (default: #ff0000)\n
  Environment variables:
    All command line parameters can be passed as environment variables
    using the name listed above, eg - set the variable TL_CONSOLE to the
    address of the Console rather than passing the -a flag. Options passed on
    the command-line override environment variables. The Console user's password
    can be passed via the TL_USER_PW environment variable\n
  Requires:
    The curl, jq, and kubectl commands.\n"

   echo -e "${docstring}" | sed 's/^  //g'
}

get_images_in_namespace() {
  kubectl get pods -n "${NAMESPACE}" -o jsonpath="{..image}" |\
  tr -s '[[:space:]]' '\n' |\
  sort |\
  uniq -c |\
  awk '{print $2}'
}

get_collections() {
  curl -s -k -u "${TL_USER}:${TL_USER_PW}" \
    -H 'Content-Type: application/json' \
    "${TL_CONSOLE_API}/${api_path}"
}

check_for_collection() {
  if $(get_collections | tr ',' '\n' | sed 's/"//g' | grep -i 'name:' |\
       cut -f2 -d: | grep -q "^${COLLECTION_NAME}$"); then
    return 0 
  fi
  return 1
}

create_collection() {
  IMAGES_STRING=$(printf -- ", \"%s\"" ${IMAGES[*]} | cut -d ',' -f 2-)
  curl -s -k -u "${TL_USER}:${TL_USER_PW}" \
    -X "${http_req_method}" \
    -H 'Content-Type: application/json' \
    -d "{ \
    \"name\":\"${COLLECTION_NAME}\", \
    \"color\":\"${COLLECTION_COLOR}\", \
    \"description\": \
    \"A collection for images within ${NAMESPACE}\", \
    \"images\":[${IMAGES_STRING}], \
    \"hosts\":[\"*\"], \
    \"containers\":[\"*\"], \
    \"labels\":[\"*\"]} \
    \"namespaces\":[\"*\"]}" \
    "${TL_CONSOLE_API}/${api_path}"
}

# use POST for a new Collection, PUT for replacing an existing Collection
http_req_method="POST"
# the base end point for defining Collections
api_path="collections"

while getopts ":hn:N:c:u:a:" OPTION; do
  case "${OPTION}" in
    n) NAMESPACE="${OPTARG}";;
    N) COLLECTION_NAME="${OPTARG}";;
    c) COLLECTION_COLOR="${OPTARG}";;
    u) TL_USER="${OPTARG}";;
    a) TL_CONSOLE="${OPTARG}";;
    h) usage
       exit 1;;
    *) usage
       echo "ERROR: unknown option -${OPTARG}"
       exit 1;;
  esac
done

arg_err=""
if [[ "${TL_USER}" == NONE ]]; then
  arg_err="missing the TL_USER argument (-u)"
fi
if [[ "${TL_CONSOLE}" == NONE ]]; then
  if [[ "${arg_err}X" == X ]] ; then
     arg_err="missing the TL_CONSOLE argument (-a)"
  else
     arg_err="${arg_err}, missing the TL_CONSOLE argument (-a)"
  fi
fi

if [[ "${arg_err}X" != X ]]; then
   usage
   echo "ERROR: ${arg_err}"
   exit 2
fi

if [[ "${TL_USER_PW}" == NONE ]]; then
   read -s -p "enter password for ${TL_USER}: " TL_USER_PW
fi

# If the Collection already exists, change the HTTP request method and the API
# end point URL appropriately for a replacement operation.
if $(check_for_collection); then
   echo -e "Found existing collection ${COLLECTION_NAME}"
   http_req_method="PUT"
   api_path="${api_path}/${COLLECTION_NAME}"
fi

echo -e "\nQuerying images in the ${NAMESPACE} namespace"
IMAGES=$(get_images_in_namespace)

echo -e "\nCreating the Collection \"${COLLECTION_NAME}\" containing the following images:"
echo "${IMAGES}" | xargs -I{} printf "  %s\n" {}
echo

# Set user prompt based on whether creating a new Collection or replacing an
# existing one.
if [[ "${http_req_method}" == POST ]]; then
  user_prompt="Continue with creation? [y/n]: "
elif [[ "${http_req_method}" == PUT ]]; then
  user_prompt="Overwrite existing collection? [y/n]: "
fi

read -n 1 -p "${user_prompt}" user_answer

while [[ "${user_answer}" != y ]] && [[ "${user_answer}" != n ]]; do
  echo -e "\nplease answer 'y' or 'n' only"
  read -n 1 -p "${user_prompt}" user_answer
done
echo

if [[ "${user_answer}" == n ]]; then
   echo "'n' was entered, exiting"
   exit 0
fi

create_collection
