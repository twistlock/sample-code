from __future__ import print_function
from datetime import date, timedelta
import json
import os
import re
import requests
import sys

forensics_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "meta", "forensics_events.txt")
checkpoint_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "meta", "serialNum_checkpoint.txt")
config_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "meta", "config.json")
config = json.load(open(config_file))

console_url = config["setup"]["console_url"]
auth_endpoint = "/api/v1/authenticate"
incidents_endpoint = "/api/v1/audits/incidents"

credentials = {"username": config["credentials"]["username"], "password": config["credentials"]["password"]}

auth_url = console_url + auth_endpoint
auth_response = requests.post(auth_url, headers={"Content-Type": "application/json"}, data=json.dumps(credentials), verify=False)
try:
    auth_response_json = auth_response.json()
except ValueError:
    print("ValueError with URL:", auth_url, file=sys.stderr)
    exit(1)

incidents_url = console_url + incidents_endpoint
incidents_header = {"Authorization": "Bearer " + auth_response_json['token']}
incidents_response = requests.get(incidents_url, headers=incidents_header, verify=False)
try:
    incidents_response_json = incidents_response.json()
except ValueError:
    print("ValueError with URL:", incidents_url, file=sys.stderr)
    exit(1)

if incidents_response_json is None:
    print("No incidents: incidents_response_json is None", file=sys.stderr)
    exit(1)

last_serialNum_indexed = 0
if (os.path.isfile(checkpoint_file)):
    with open(checkpoint_file) as file:
        last_serialNum_indexed = int(file.readline())

field_extracts = []
highest_serialNum = 0
for element in incidents_response_json:
    current_serialNum = element["serialNum"]
    # Print new incidents for indexing in Splunk
    if (current_serialNum > last_serialNum_indexed):
        print(json.dumps(element))

        # Determine whether the incident is from a host or container and write to file for processing
        if (re.match(r'sha256:[a-f0-9]{64}_', element["profileID"])):
            element_values = {"_id": element["_id"], "profileID": element["profileID"], "type": "container"}
        else:
            element_values = {"_id": element["_id"], "profileID": element["hostname"], "type": "host"}
        if element_values not in field_extracts:
            field_extracts.append(element_values)

        if (current_serialNum > highest_serialNum):
            highest_serialNum = current_serialNum

if (highest_serialNum > last_serialNum_indexed):
    with open(checkpoint_file, 'w') as file:
        print(highest_serialNum, file=file)

json.dump(field_extracts, open(forensics_file, 'w'))
