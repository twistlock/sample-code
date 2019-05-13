from __future__ import print_function
from datetime import date, timedelta
import json
import os
import re
import requests
import sys

forensics_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "Splunk_TA_twistlock-forensics-19-03", "bin", "forensics_events.txt")
last_date_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "Splunk_TA_twistlock-forensics-19-03", "bin", "last_date.txt")
config_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "Splunk_TA_twistlock-forensics-19-03", "bin", "config.json")
config = json.load(open(config_file))

console_fqdn = config["setup"]["console_fqdn"]
endpoint = config["setup"]["incidents_endpoint"]

username = config["credentials"]["username"]
password = config["credentials"]["password"]

url = console_fqdn + endpoint
if (os.path.isfile(last_date_file)):
    with open(last_date_file) as file:
        url = url + "?from=" + str(file.readline())

response = requests.get(url, auth=(username, password))
try:
    json_response = response.json()
    if json_response is None:
        print("No incidents: json_response is None", file=sys.stderr)
        exit(1)
    print(json.dumps(json_response))
except ValueError:
    print("ValueError with URL:", url, file=sys.stderr)
    exit(1)

field_extracts = []
for element in json_response:
    if (re.match(r'sha256:[a-f0-9]{64}_', element["profileID"])):
        element_values = {"type": "container", "profileID": element["profileID"], "hostname": element["hostname"]}
    else:
        element_values = {"type": "host", "profileID": element["hostname"], "hostname": element["hostname"]}
    if element_values not in field_extracts:
        field_extracts.append(element_values)

json.dump(field_extracts, open(forensics_file, 'w'))

with open(last_date_file, 'w') as file:
    print(str(date.today()), file=file, end='')
