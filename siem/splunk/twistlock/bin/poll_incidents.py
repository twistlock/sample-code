from __future__ import print_function
import json
import os
import re
import sys
import requests
try:
    from urllib.parse import urljoin
except ImportError:
    from urlparse import urljoin
from api_wrappers import get_auth_token, get_projects

data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")

config_file = os.path.join(data_dir, "config.json") # global variable
config = json.load(open(config_file)) # global variable
forensics_file = os.path.join(data_dir, "incidents_list.txt")

def get_incidents(console_url, auth_token, project_list, last_indexed, console_id):
    endpoint = "/api/v1/audits/incidents"
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_limit = 50
    request_url = urljoin(console_url, endpoint)
    current_incidents = [] # Used to store the information needed to pull forensics
    last_serialNum_indexed = last_indexed

    for project in project_list:
        # Make a call to get count of incidents
        params = {"project": project, "acknowledged": "false", "limit": 1, "offset": 0}
        params_string = "&".join("%s=%s" % (k,v) for k,v in params.items())
        try:
            response = requests.get(request_url, params=params_string, headers=headers, verify=False)
            response.raise_for_status()
            total_count = int(response.headers["Total-Count"])
        except (requests.exceptions.RequestException, ValueError) as req_err:
            print("Failed getting incidents count for {}\n{}".format(project, req_err), file=sys.stderr)
            continue

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
                response = requests.get(request_url, params=params_string, headers=headers, verify=False)
                response.raise_for_status()
                response_json = response.json()
            except (requests.exceptions.RequestException, ValueError) as req_err:
                print("Failed getting incidents\n{}".format(req_err), file=sys.stderr)
                break

            if response_json is None:
                print("Unusually empty response", file=sys.stderr)
                break

            highest_serialNum = 0
            for incident in response_json:
                current_serialNum = incident["serialNum"]
                incident["console"] = console_url
                # Print only new incidents for indexing in Splunk
                if current_serialNum > last_serialNum_indexed:
                    # Add project key for associating in Splunk
                    incident["project"] = project
                    print(json.dumps(incident))
                else:
                    continue

                # Determine whether the incident is from a host or container and add to list of incidents
                if re.match(r"sha256:[a-f0-9]{64}_*", incident["profileID"]): # if profileID is a SHA256 sum => container
                    incident_info = {"project": project, "_id": incident["_id"], "profileID": incident["profileID"], "type": "container", "url": incident["console"]}
                else: # else => host
                    incident_info = {"project": project, "_id": incident["_id"], "profileID": incident["hostname"], "type": "host", "url": incident["console"] }
                if incident_info not in current_incidents:
                    current_incidents.append(incident_info)

                if current_serialNum > highest_serialNum:
                    highest_serialNum = current_serialNum

        # Update the checkpoint file
        if highest_serialNum >= last_serialNum_indexed:
            config["consoles"][console_id]["lastIndexed"] = highest_serialNum
            with open(config_file, "w") as f:
                json.dump(config,f)

    # Write the collected info to a file for poll-forensics.py.
    # If forensics file already exists append newly-collected incidents to what
    # was previously collected and stick that back in forensics file.
    if os.path.isfile(forensics_file):
        previous_incidents = json.load(open(forensics_file))
        for incident in current_incidents:
            if incident not in previous_incidents:
                previous_incidents.append(incident)
        with open(forensics_file, "w") as f:
            # At this point, previous_incidents list will have any new incidents appended
            json.dump(previous_incidents, f)
    else:
        with open(forensics_file, "w") as f:
            json.dump(current_incidents, f)


if __name__ == "__main__":
    if not (config["consoles"][0]["url"] and config["consoles"][0]["credentials"]["username"] and config["consoles"][0]["credentials"]["username"]):
        print("At least one item is missing in config.json", file=sys.stderr)
        sys.exit(1)
    for console in range(0,len(config["consoles"])):
        username = config["consoles"][console]["credentials"]["username"]
        password = config["consoles"][console]["credentials"]["password"]
        console_url = config["consoles"][console]["url"]
        try:
            config["consoles"][console]["lastIndexed"]
            last_indexed = config["consoles"][console]["lastIndexed"] 
        except KeyError:
            config["consoles"][console]["lastIndexed"] = 0
            last_indexed = 0
        auth_token = get_auth_token(console_url, username, password)
        # Check if supplied Console address is SaaS or not
        # SaaS does not have projects, so use default value
        if "cloud.twistlock.com/" in console_url:
            projects = ["Central Console"]
        else:
            # Try to handle user-specified projects
            if type(config["consoles"][console]["projects"]) is list:
                projects = config["consoles"][console]["projects"]
            elif config["consoles"][console]["projects"].lower() == "all":
                projects = get_projects(console_url, auth_token)
            else:
                print("console.projects in config.json is invalid: ", config["consoles"][console]["projects"], file=sys.stderr)
                sys.exit(1)
        get_incidents(console_url, auth_token, projects, last_indexed, console)
