from __future__ import print_function
import json
import os
import requests
import sys

# forensics_file - listing of all incidents pulled by poll-incidents.py)
# it is not persistent between runs
forensics_file = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data", "forensics_events.txt")

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


def get_forensics(console_url, username, password):
    forensics_endpoint = "/api/v1/profiles/"
    forensics_headers = {"Authorization": "Bearer " + get_auth_token(console_url, username, password), "Accept": "application/json"}
    request_limit = 500

    field_extracts = json.load(open(forensics_file))
    for field in field_extracts:
        forensics_params = {"project": "Central+Console", "limit": request_limit, "incidentID": field["_id"]}
        forensics_params_string = "&".join("%s=%s" % (k,v) for k,v in forensics_params.items())
        forensics_url = console_url + forensics_endpoint + field["type"] + "/" + field["profileID"] + "/forensic"
        try:
            forensics_response = requests.get(forensics_url, params=forensics_params_string, headers=forensics_headers)
            forensics_response.raise_for_status()
            forensics_response_json = forensics_response.json()
        except (requests.exceptions.RequestException, ValueError) as forensics_req_err:
            print("Failed getting forensics\nincidentID: {}\nprofileID: {}\n{}".format(field['_id'], field['profileID'], forensics_req_err), file=sys.stderr)

        if forensics_response_json is not None:
            # Add incident ID to forensic data
            for element in forensics_response_json:
                element["incidentID"] = field["_id"]
                print(json.dumps(element))

    os.remove(forensics_file)


if __name__ == "__main__":
    if (os.path.isfile(forensics_file)):
        config = json.load(open(config_file))

        if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
            print("At least one item is missing in config.json", file=sys.stderr)
            sys.exit(1)
        
        get_forensics(config["console"]["url"], config["credentials"]["username"], config["credentials"]["password"])
    else:
        print("Forensics file not found", file=sys.stderr)
