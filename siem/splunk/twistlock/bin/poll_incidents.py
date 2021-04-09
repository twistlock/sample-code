"""Collects incidents from a Prisma Cloud Compute Console.

This script is intended to be used as a Splunk input, so it is not tested
outside of Splunk. Please see the README.md in the app's root directory for
setup instructions.
"""

import json
import logging
import os
import re
import sys

import requests

from api_wrappers import get_auth_token, get_projects, slash_join

# Set up logger for Splunk compatibility
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(levelname)s %(message)s")
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)

data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")
config_file = os.path.join(data_dir, "config.json")
incidents_file = os.path.join(data_dir, "incidents_list.txt")


def get_incidents(console_url, auth_token, project_list):
    endpoint = "/api/v1/audits/incidents"
    headers = {
        "Authorization": "Bearer " + auth_token,
        "Accept": "application/json",
    }
    request_limit = 50
    request_url = slash_join(console_url, endpoint)
    current_incidents = []

    for project in project_list:
        # checkpoint_file stores the highest incident serialNum ingested to
        # only pull the latest incidents
        checkpoint_file = os.path.join(data_dir, project.replace(" ", "-").lower() + "_serialNum_checkpoint.txt")
        # If the checkpoint file exists, use it. If not, start at 0.
        if os.path.isfile(checkpoint_file):
            with open(checkpoint_file) as f:
                try:
                    last_serialNum_indexed = int(f.readline())
                except Exception as err:
                    logger.error("Unexpected content in checkpoint file. Exiting.")
                    sys.exit(err)
        else:
            last_serialNum_indexed = 0

        # Make a call to get count of incidents
        params = {
            "project": project,
            "acknowledged": "false",
            "limit": 1,
            "offset": 0,
        }
        params_string = "&".join("{0}={1}".format(k, v) for k, v in params.items())
        try:
            response = requests.get(request_url, params=params_string, headers=headers)
            response.raise_for_status()
            total_count = int(response.headers["Total-Count"])
        except (requests.exceptions.RequestException, ValueError) as req_err:
            logger.warning("Failed getting incidents count for {}. Error: {}. Continuing.".format(project, req_err))
            continue

        if total_count < 1:
            logger.warning("No incidents to ingest for {}. Continuing.".format(project))
            continue

        highest_serialNum = 0
        # Use that count to create offsets
        # Example: 85 incidents
        # offset: 0, limit: 50 = 1-50
        # offset: 50, limit: 50 = 51-85
        # offset: 100 > 85 = break
        for request_offset in range(0, total_count, 50):
            params = {
                "project": project,
                "acknowledged": "false",
                "limit": request_limit,
                "offset": request_offset,
            }
            params_string = "&".join("{0}={1}".format(k, v) for k, v in params.items())

            try:
                response = requests.get(request_url, params=params_string, headers=headers)
                response.raise_for_status()
                response_json = response.json()
            except (requests.exceptions.RequestException, ValueError) as req_err:
                logger.warning("Failed getting incidents for {}. Error: {}. Continuing.".format(project, req_err))
                break

            if response_json is None:
                logger.warning("Unusually empty response from {} using limit {} and offset {}. Continuing.".format(project, request_limit, request_offset))
                break

            for incident in response_json:
                current_serialNum = incident["serialNum"]
                # Print only new incidents for indexing in Splunk
                if current_serialNum > last_serialNum_indexed:
                    # Add project key for associating in Splunk
                    incident["project"] = project
                    print(json.dumps(incident))
                else:
                    continue

                # Determine whether the incident is from a host or container and add to list of incidents
                if re.match(r"sha256:[a-f0-9]{64}_*", incident["profileID"]): # if profileID is a SHA256 sum => container
                    incident_info = {
                        "project": project,
                        "_id": incident["_id"],
                        "profileID": incident["profileID"],
                        "type": "container",
                    }
                else: # else => host
                    incident_info = {
                        "project": project,
                        "_id": incident["_id"],
                        "profileID": incident["hostname"],
                        "type": "host",
                    }
                if incident_info not in current_incidents:
                    current_incidents.append(incident_info)

                if current_serialNum > highest_serialNum:
                    highest_serialNum = current_serialNum

        # Update the checkpoint file
        if highest_serialNum > last_serialNum_indexed:
            with open(checkpoint_file, "w") as f:
                f.write(str(highest_serialNum))
        else:
            logger.info("No new incidents to ingest for {}. Continuing.".format(project))

    # Write the collected info to a file for poll-forensics.py.
    # If incidents file already exists append newly-collected incidents to what
    # was previously collected and stick that back in incidents file.
    if os.path.isfile(incidents_file):
        previous_incidents = json.load(open(incidents_file))
        for incident in current_incidents:
            if incident not in previous_incidents:
                previous_incidents.append(incident)
        with open(incidents_file, "w") as f:
            # At this point, previous_incidents list will have any new incidents appended
            json.dump(previous_incidents, f)
    else:
        with open(incidents_file, "w") as f:
            json.dump(current_incidents, f)
            
if __name__ == "__main__":
    logger.info("Prisma Cloud Compute poll_incidents script started.")
    config = json.load(open(config_file))

    if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
        logger.error("At least one item is missing in config.json. Please see README.md for more information. Exiting.")
        sys.exit(1)

    username = config["credentials"]["username"]
    password = config["credentials"]["password"]
    console_url = config["console"]["url"]

    auth_token = get_auth_token(console_url, username, password)

    # Check if supplied Console address is SaaS or not
    # SaaS does not have projects, so use default value
    if "cloud.twistlock.com/" in console_url:
        projects = ["Central Console"]
    else:
        # Try to handle user-specified projects
        if type(config["console"]["projects"]) is list:
            projects = config["console"]["projects"]
        elif config["console"]["projects"].lower() == "all":
            projects = get_projects(console_url, auth_token)
        else:
            logger.error("console.projects in config.json is invalid: {}. Exiting.".format(config["console"]["projects"]))
            sys.exit(1)

    get_incidents(console_url, auth_token, projects)
    logger.info("Prisma Cloud Compute poll_incidents script ending.")
