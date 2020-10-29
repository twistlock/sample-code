from __future__ import print_function
import json
import os
import re
import requests
import sys

# forensics_file - listing of all incidents pulled by this script (used by poll-forensics.py)
# it is not persistent between runs
forensics_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data", "forensics_events.txt")

# checkpoint_file - stores the highest incident serialNum ingested for only pulling the latest incidents
checkpoint_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data", "serialNum_checkpoint.txt")

# config_file - stores the Console URL and authentication information
config_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data", "config.json")

def get_auth_token(console_url, username, password):
    auth_endpoint = "/api/v1/authenticate"
    auth_params = {"project": "Central+Console"}
    auth_params_string = "&".join("%s=%s" % (k,v) for k,v in auth_params.items())
    auth_headers = {"Content-Type": "application/json", "Accept": "application/json"}
    auth_data = {"username": username, "password": password}
    auth_request_url = console_url + auth_endpoint

    try:
        auth_response = requests.post(auth_request_url, params=auth_params_string, headers=auth_headers, data=json.dumps(auth_data))
        auth_response.raise_for_status()
        auth_response_json = auth_response.json()
    except (requests.exceptions.RequestException, ValueError) as auth_req_err:
        print("Failed getting auth token", file=sys.stderr)
        sys.exit(auth_req_err)

    return auth_response_json["token"]


def get_incidents(console_url, username, password):
    incidents_endpoint = "/api/v1/audits/incidents"
    incidents_headers = {"Authorization": "Bearer " + get_auth_token(console_url, username, password), "Accept": "application/json"}
    request_limit = 50
    request_offset = 0
    incidents_request_url = console_url + incidents_endpoint

    # If the checkpoint file exists, use it. If not, start at 0.
    if (os.path.isfile(checkpoint_file)):
        with open(checkpoint_file) as file:
            try:
                last_serialNum_indexed = int(file.readline())
            except Exception as err:
                print("Unexpected content in checkpoint file", file=sys.stderr)
                sys.exit(err)
    else:
        last_serialNum_indexed = 0

    while True:
        incidents_params = {"project": "Central+Console", "acknowledged": "false", "limit": request_limit, "offset": request_offset}
        incidents_params_string = "&".join("%s=%s" % (k,v) for k,v in incidents_params.items())

        try:
            incidents_response = requests.get(incidents_request_url, params=incidents_params_string, headers=incidents_headers)
            incidents_response.raise_for_status()
            incidents_response_json = incidents_response.json()
        except (requests.exceptions.RequestException, ValueError) as incidents_req_err:
            print("Failed getting incidents", file=sys.stderr)
            sys.exit(incidents_req_err)

        if incidents_response_json is None:
            break

        field_extracts = [] # Used to store the information needed to pull forensics
        highest_serialNum = 0
        for element in incidents_response_json:
            current_serialNum = element["serialNum"]
            # Print only new incidents for indexing in Splunk
            if (current_serialNum > last_serialNum_indexed):
                print(json.dumps(element))
            else:
                request_offset = request_offset + 50
                continue

            # Determine whether the incident is from a host or container and write to file for processing
            if (re.match(r'sha256:[a-f0-9]{64}_*', element["profileID"])): # if profileID is a SHA256 sum => container
                element_values = {"_id": element["_id"], "profileID": element["profileID"], "type": "container"}
            else: # else => host
                element_values = {"_id": element["_id"], "profileID": element["hostname"], "type": "host"}
            if element_values not in field_extracts:
                field_extracts.append(element_values)

            if (current_serialNum > highest_serialNum):
                highest_serialNum = current_serialNum

        request_offset = request_offset + 50

    # Update the checkpoint file
    if (highest_serialNum >= last_serialNum_indexed):
        with open(checkpoint_file, 'w') as file:
            print(highest_serialNum, file=file)

    json.dump(field_extracts, open(forensics_file, 'w')) # Write the collected info to a file for poll-forensics.py

if __name__ == "__main__":
    config = json.load(open(config_file))

    if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
        print("At least one item is missing in config.json", file=sys.stderr)
        sys.exit(1)
    
    get_incidents(config["console"]["url"], config["credentials"]["username"], config["credentials"]["password"])
