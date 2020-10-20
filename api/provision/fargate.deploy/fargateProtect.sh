#!/usr/bin/env bash

# https://cdn.twistlock.com/docs/downloads/Twistlock-API.html#defenders_fargate_json_post

# Edit these 3 values for your SaaS instance
export PC_ADDR=""
export PC_TOKEN=""
export PC_KEY=""


export PC_CONSOLE="https://${PC_ADDR}"

echo -e "Prisma Cloud Console:\n$PC_CONSOLE\n"

generate_post_data()
{
   cat <<EOF
{
       "username":"$PC_TOKEN", 
       "password":"$PC_KEY"
} 
EOF
}   

OPTIONS=" -k -s"
HEADER="Content-Type: application/json"



TOKEN=$(curl ${OPTIONS} -H "${HEADER}"  --data "$(generate_post_data)"  "${PC_CONSOLE}/api/v1/authenticate" | python -c 'import sys, json; print json.load(sys.stdin)["token"]' )

echo -e "Create access token with access Key:\n $TOKEN\n"

unprotectedTask=unprotectedTask.json

echo -e "\ncurl ${OPTIONS} -H \"Authorization: Bearer ${TOKEN}\" \"${PC_CONSOLE}/api/v1/defenders/fargate.json?consoleaddr=${PC_ADDR}&defenderType=appEmbedded\" -X POST --data-binary "@${unprotectedTask}" --output protectedTask.json\n\n"

curl ${OPTIONS} -H "Authorization: Bearer ${TOKEN}" "${PC_CONSOLE}/api/v1/defenders/fargate.json?consoleaddr=${PC_ADDR}&defenderType=appEmbedded" -X POST --data-binary "@${unprotectedTask}" --output protectedTask.json

