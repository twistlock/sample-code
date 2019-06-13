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

console_fqdn = config["setup"]["console_fqdn"]
username = config["credentials"]["username"]
password = config["credentials"]["password"]

url = console_fqdn + "/api/v1/audits/incidents"

response = requests.get(url, auth=(username, password))

try:
    json_response = response.json()
except ValueError:
    print("ValueError with URL:", url, file=sys.stderr)
    exit(1)

if json_response is None:
    print("No incidents: json_response is None", file=sys.stderr)
    exit(1)

last_serialNum_indexed = 0
if (os.path.isfile(checkpoint_file)):
    with open(checkpoint_file) as file:
        last_serialNum_indexed = int(file.readline())

field_extracts = []
highest_serialNum = 0
for element in json_response:
    current_serialNum = element["serialNum"]
    # Print new incidents for indexing in Splunk
    if (current_serialNum > last_serialNum_indexed):
        print(json.dumps(element))

        # Determine whether the incident is from a host or container and write to file for processing
        if (re.match(r'sha256:[a-f0-9]{64}_', element["profileID"])):
            element_values = {"type": "container", "profileID": element["profileID"], "hostname": element["hostname"]}
        else:
            element_values = {"type": "host", "profileID": element["hostname"], "hostname": element["hostname"]}
        if element_values not in field_extracts:
            field_extracts.append(element_values)

        if (current_serialNum > highest_serialNum):
            highest_serialNum = current_serialNum

if (highest_serialNum > last_serialNum_indexed):
    with open(checkpoint_file, 'w') as file:
        print(highest_serialNum, file=file)

json.dump(field_extracts, open(forensics_file, 'w'))
