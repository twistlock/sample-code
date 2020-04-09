from __future__ import print_function
from datetime import date, timedelta
import json
import os
import requests
import sys

forensics_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "meta", "forensics_events.txt")
config_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "meta", "config.json")
config = json.load(open(config_file))

console_url = config["setup"]["console_url"]
auth_endpoint = "/api/v1/authenticate"
forensics_endpoint = "/api/v1/profiles/"

credentials = {"username": config["credentials"]["username"], "password": config["credentials"]["password"]}

if (os.path.isfile(forensics_file)):
    auth_url = console_url + auth_endpoint
    auth_response = requests.post(auth_url, headers={"Content-Type": "application/json"}, data=json.dumps(credentials), verify=False)
    try:
        auth_response_json = auth_response.json()
    except ValueError:
        print("ValueError with URL:", auth_url, file=sys.stderr)
        exit(1)

    field_extracts = json.load(open(forensics_file))

    for field in field_extracts:
        forensics_url = console_url + forensics_endpoint + field["type"] + "/" + field["profileID"] + "/forensic?incidentID=" + field["_id"] + "&limit=500"
        forensics_header = {"Authorization": "Bearer " + auth_response_json['token']}
        forensics_response = requests.get(forensics_url, headers=forensics_header, verify=False)
        try:
            forensics_response_json = forensics_response.json()
        except ValueError:
            print("ValueError with URL:", forensics_url, file=sys.stderr)
            exit(1)

        if forensics_response_json is not None:
            # Add incident ID to forensic data
            for element in forensics_response_json:
                element["incidentID"] = field["_id"]
                print(json.dumps(element))

    os.remove(forensics_file)
else:
    print("No forensics: forensics file not created by poll-incidents.py", file=sys.stderr)
