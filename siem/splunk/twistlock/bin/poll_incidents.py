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

from utils.compute import get_auth_token, get_projects, slash_join
from utils.splunk import generate_configs

# Set up logger for Splunk compatibility
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(levelname)s %(message)s")
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)

data_dir = os.path.join(os.path.dirname(__file__), "data")
incidents_file = os.path.join(data_dir, "incidents_list.txt")

try:
    os.mkdir(data_dir)
except OSError:
    if not os.path.isdir(data_dir):
        raise


def get_incidents(console_name, console_url, project_list, auth_token):
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
        # `my-console_my-project_serialNum_checkpoint.txt`
        checkpoint_file = os.path.join(
            data_dir,
            console_name.replace(" ", "-").lower()
            + project.replace(" ", "-").lower()
            + "_serialNum_checkpoint.txt")
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
        joined_params = "&".join("{0}={1}".format(k, v) for k, v in params.items())
        try:
            response = requests.get(request_url, params=joined_params, headers=headers)
            response.raise_for_status()
            total_count = int(response.headers["Total-Count"])
        except (requests.exceptions.RequestException, ValueError) as req_err:
            logger.warning(
                "Failed getting incident count from Console: %s, project: %s. "
                "Error: %r. Continuing.", console_name, project, req_err)
            continue

        if total_count < 1:
            logger.warning("No incidents to ingest for %s. Continuing.", project)
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
            joined_params = "&".join("{0}={1}".format(k, v) for k, v in params.items())

            try:
                response = requests.get(
                    request_url, params=joined_params, headers=headers)
                response.raise_for_status()
                response_json = response.json()
            except (requests.exceptions.RequestException, ValueError) as req_err:
                logger.warning(
                    "Failed getting incidents from Console: %s, project: %s. "
                    "Error: %r. Continuing.", console_name, project, req_err)
                break

            if response_json is None:
                logger.warning(
                    "Empty response from Console: %s, project: %s "
                    "using limit %s and offset %s. Continuing.",
                    console_name, project, request_limit, request_offset)
                break

            for incident in response_json:
                current_serialNum = incident["serialNum"]
                # Print only new incidents for indexing in Splunk
                if current_serialNum > last_serialNum_indexed:
                    # Add console and project keys for associating in Splunk
                    incident["console"] = console_name
                    incident["project"] = project
                    print(json.dumps(incident))
                else:
                    continue

                # Determine whether the incident is from a host or container
                # and add to list of incidents
                # if profileID is a SHA256 sum => container
                if re.match(r"sha256:[a-f0-9]{64}_*", incident["profileID"]):
                    incident_info = {
                        "console": console_name,
                        "project": project,
                        "_id": incident["_id"],
                        "profileID": incident["profileID"],
                        "type": "container",
                        "attempted": False,
                        "poll_attempts": 0,
                    }
                # else => host
                else:
                    incident_info = {
                        "console": console_name,
                        "project": project,
                        "_id": incident["_id"],
                        "profileID": incident["hostname"],
                        "type": "host",
                        "attempted": False,
                        "poll_attempts": 0,
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
            logger.info(
                "No new incidents to ingest from Console: %s, project: %s. "
                "Continuing.", console_name, project)

    # Write the collected info to a file for poll-forensics.py.
    # If incidents file already exists append newly-collected incidents to what
    # was previously collected and stick that back in incidents file.
    if os.path.isfile(incidents_file):
        past_incidents = json.load(open(incidents_file))
        for incident in current_incidents:
            if not any(
                    past_incident["_id"] == incident["_id"]
                    for past_incident
                    in past_incidents):
                past_incidents.append(incident)
        with open(incidents_file, "w") as f:
            # At this point, past_incidents list will have any new incidents appended
            json.dump(past_incidents, f)
    else:
        with open(incidents_file, "w") as f:
            json.dump(current_incidents, f)


def main():
    logger.info("Prisma Cloud Compute poll_incidents script started.")
    session_key = sys.stdin.readline().strip()
    configs = generate_configs(session_key)

    for config in configs:
        if not (config["console_addr"] and config["username"] and config["password"]):
            logger.error(
                "At least one configuration item is missing. "
                "Please see README.md for more information. Exiting.")
            sys.exit(1)

        console_name = config["realm"]
        console_url = config["console_addr"]
        username = config["username"]
        password = config["password"]

        auth_token = get_auth_token(console_url, username, password)

        # Check if supplied Console address is SaaS or not
        # SaaS does not have projects, so use default value
        if "cloud.twistlock.com/" in console_url:
            projects = ["Central Console"]
        else:
            # Try to handle user-specified projects
            if type(config["projects"]) is list:
                projects = config["projects"]
            elif config["projects"].lower() == "all":
                projects = get_projects(console_url, auth_token)
            else:
                logger.error("Bad projects value: %s. Exiting.", config["projects"])
                sys.exit(1)

        get_incidents(console_name, console_url, projects, auth_token)
    logger.info("Prisma Cloud Compute poll_incidents script ending.")


if __name__ == "__main__":
    main()
