from __future__ import print_function
import json
import os
import re
import requests
import sys

from api_wrappers import get_auth_token, get_projects


data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")

config_file = os.path.join(data_dir, "config.json")
forensics_file = os.path.join(data_dir, "forensics_events.txt")

def get_incidents(console_url, auth_token, project_list):
    endpoint = "/api/v1/audits/incidents"
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_limit = 50
    request_url = console_url + endpoint
    field_extracts = [] # Used to store the information needed to pull forensics

    for project in project_list:
        # checkpoint_file stores the highest incident serialNum ingested to only pull the latest incidents
        checkpoint_file = os.path.join(data_dir, project.replace(' ', '-').lower() + "_serialNum_checkpoint.txt")
        # If the checkpoint file exists, use it. If not, start at 0.
        if os.path.isfile(checkpoint_file):
            with open(checkpoint_file) as f:
                try:
                    last_serialNum_indexed = int(f.readline())
                except Exception as err:
                    print("Unexpected content in checkpoint file", file=sys.stderr)
                    sys.exit(err)
        else:
            last_serialNum_indexed = 0

        # Make a call to get count of incidents
        params = {"project": project, "acknowledged": "false", "limit": 1, "offset": 0}
        params_string = "&".join("%s=%s" % (k,v) for k,v in params.items())
        try:
            response = requests.get(request_url, params=params_string, headers=headers)
            response.raise_for_status()
            total_count = int(response.headers["Total-Count"])
        except (requests.exceptions.RequestException, ValueError) as req_err:
            print("Failed getting incidents count", file=sys.stderr)
            sys.exit(req_err)

        if total_count < 1:
            print("No unacknowledged incidents found for", project, file=sys.stderr)
            continue

        # Use that count to create offsets
        # Example: 85 incidents
        # offset: 0, limit: 50 = 1-50
        # offset: 50, limit: 50 = 51-85
        # offset: 100 > 85 = break
        for offset in range(0, total_count, 50):
            params = {"project": project, "acknowledged": "false", "limit": request_limit, "offset": offset}
            params_string = "&".join("%s=%s" % (k,v) for k,v in params.items())

            try:
                response = requests.get(request_url, params=params_string, headers=headers)
                response.raise_for_status()
                response_json = response.json()
            except (requests.exceptions.RequestException, ValueError) as req_err:
                print("Failed getting incidents", file=sys.stderr)
                # TODO: break instead of exit?
                sys.exit(req_err)

            if response_json is None:
                print("Unusually empty response", file=sys.stderr)
                break

            highest_serialNum = 0
            for element in response_json:
                current_serialNum = element["serialNum"]
                # Print only new incidents for indexing in Splunk
                if current_serialNum > last_serialNum_indexed:
                    element["project"] = project
                    print(json.dumps(element))
                else:
                    continue

                # Determine whether the incident is from a host or container and write to file for processing
                if re.match(r'sha256:[a-f0-9]{64}_*', element["profileID"]): # if profileID is a SHA256 sum => container
                    element_values = {"project": project, "_id": element["_id"], "profileID": element["profileID"], "type": "container"}
                else: # else => host
                    element_values = {"project": project, "_id": element["_id"], "profileID": element["hostname"], "type": "host"}
                if element_values not in field_extracts:
                    field_extracts.append(element_values)

                if current_serialNum > highest_serialNum:
                    highest_serialNum = current_serialNum

        # Update the checkpoint file
        if highest_serialNum >= last_serialNum_indexed:
            with open(checkpoint_file, 'w') as file:
                print(highest_serialNum, file=file)
    
    # Write the collected info to a file for poll-forensics.py
    if os.path.isfile(forensics_file):
        forensics = json.load(open(forensics_file))
        for event in forensics:
            if event not in field_extracts:
                field_extracts.append(event)
        with open(forensics_file, 'w') as f:
            json.dump(field_extracts, f)                                                                                           
    else:
        with open(forensics_file, 'w') as f:
            json.dump(field_extracts, f)
            
if __name__ == "__main__":
    config = json.load(open(config_file))

    if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
        print("At least one item is missing in config.json", file=sys.stderr)
        sys.exit(1)

    username = config["credentials"]["username"]
    password = config["credentials"]["password"]
    console_url = config["console"]["url"]

    auth_token = get_auth_token(console_url, username, password)["token"]

    # Check if supplied Console address is SaaS or not
    # SaaS does not have projects, so use default value
    if "cloud.twistlock.com/" in console_url:
        projects = ["Central Console"]
    else:
        # Try to handle user-specified projects
        if type(config["console"]["projects"]) is list:
            projects = config["console"]["projects"]
        elif config["console"]["projects"].lower() == "all":
            projects_json = get_projects(console_url, auth_token)
            projects = ["Central Console"] # Central Console doesn't show up in projects list, so explicitly add it here.
            for item in projects_json:
                projects.append(item["_id"])
        else:
            print("console.projects in config.json is invalid: ", config["console"]["projects"], file=sys.stderr)
            sys.exit(1)

    get_incidents(console_url, auth_token, projects)
