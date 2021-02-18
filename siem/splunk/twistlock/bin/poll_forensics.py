from __future__ import print_function
import json
import os
import requests
import sys

from api_wrappers import get_auth_token


data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")

# config_file - stores the Console URL and authentication information
config_file = os.path.join(data_dir, "config.json")

forensics_file = os.path.join(data_dir, "forensics_events.txt")

def get_forensics(console_url, auth_token):
    endpoint = "/api/v1/profiles/"
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_limit = 500

    with open(forensics_file) as f:
        field_extracts = json.load(f)
    
    for field in field_extracts:
        params = {"project": field["project"], "limit": request_limit, "incidentID": field["_id"]}
        params_string = "&".join("%s=%s" % (k,v) for k,v in params.items())
        url = console_url + endpoint + field["type"] + "/" + field["profileID"] + "/forensic"
        try:
            response = requests.get(url, params=params_string, headers=headers)
            response.raise_for_status()
            response_json = response.json()
        except (requests.exceptions.RequestException, ValueError) as req_err:
            print("Failed getting forensics\nincidentID: {}\nprofileID: {}\n{}".format(field['_id'], field['profileID'], req_err), file=sys.stderr)
            continue

        if response_json is not None:
            # Add incident ID to forensic data
            for element in response_json:
                element["incidentID"] = field["_id"]
                print(json.dumps(element))

    os.remove(forensics_file)


if __name__ == "__main__":
    if (os.path.isfile(forensics_file)):
        config = json.load(open(config_file))

        if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
            print("At least one item is missing in config.json", file=sys.stderr)
            sys.exit(1)
        
        username = config["credentials"]["username"]
        password = config["credentials"]["password"]
        console_url = config["console"]["url"]

        auth_token = get_auth_token(console_url, username, password)
        get_forensics(console_url, auth_token)
    else:
        print("Forensics file not found", file=sys.stderr)
