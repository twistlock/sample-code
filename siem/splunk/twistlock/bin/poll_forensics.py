"""Collects forensic data from a Prisma Cloud Compute Console.

This script is intended to be used as a Splunk input, so it is not tested
outside of Splunk. Please see the README.md in the app's root directory for
setup instructions.
"""

import json
import logging
import os
import sys

import requests

from utils.compute import get_auth_token, slash_join
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


def get_forensics(console_name, console_url, auth_token):
    endpoint = "/api/v1/profiles/"
    headers = {
        "Authorization": "Bearer " + auth_token,
        "Accept": "application/json",
    }
    request_limit = 500

    with open(incidents_file, "r+") as f:
        incidents = json.load(f)
        if not incidents:
            logger.info("No new forensic data to ingest.")

        for incident in incidents:
            incident["attempted"] = False
        while incidents:
            incident = incidents.pop(0)
            # If an incident has already been attempted,
            # then we're back at the beginning of the list
            if incident["attempted"]:
                break

            incident["attempted"] = True
            incident["poll_attempts"] += 1
            logger.debug(
                "Processing incidentID %s from Console: %s, project: %s. "
                "Attempt #%s.", incident["_id"], incident["console"],
                incident["project"], incident["poll_attempts"])
            params = {
                "project": incident["project"],
                "limit": request_limit,
                "incidentID": incident["_id"],
            }
            joined_params = "&".join("{0}={1}".format(k, v) for k, v in params.items())
            request_url = slash_join(
                console_url, endpoint, incident["type"],
                incident["profileID"], "forensic")
            try:
                response = requests.get(
                    request_url, params=joined_params, headers=headers)
                response.raise_for_status()
                response_json = response.json()
                if response_json is not None:
                    logger.debug(
                        "Successfully processed incidentID: %s "
                        "from Console: %s, project: %s.",
                        incident["_id"], incident["console"], incident["project"])
                    # Add incident ID, console, and project to forensic data.
                    # With multi-Console polling, incident ID is no longer
                    # guaranteed to be unique.
                    for forensic in response_json:
                        forensic["incidentID"] = incident["_id"]
                        forensic["console"] = incident["console"]
                        forensic["project"] = incident["project"]

                        print(json.dumps(forensic))
            except (requests.exceptions.RequestException, ValueError) as req_err:
                logger.warning(
                    "Failed getting forensics for "
                    "incidentID: %s, profileID: %s, Console %s, project: %s "
                    "Error: %r. Continuing.",
                    incident["_id"], incident["profileID"],
                    incident["console"], incident["project"], req_err)
                # Save for next time and keep going
                incidents.append(incident)
            except Exception as e:
                logger.error("Unexpected error: %r", e)
                # Save for next time and keep going
                incidents.append(incident)

            # Keep file up-to-date with unprocessed incidents
            f.truncate(0)
            f.seek(0)
            json.dump(incidents, f)
            f.flush()


def main():
    logger.info("Prisma Cloud Compute poll_forensics script started.")
    if (os.path.isfile(incidents_file)):
        session_key = sys.stdin.readline().strip()
        configs = generate_configs(session_key)

        for config in configs:
            if not (config["console_addr"]
                    and config["username"]
                    and config["password"]):
                logger.error(
                    "At least one configuration item is missing. "
                    "Please see README.md for more information. Exiting.")
                sys.exit(1)

            console_name = config["realm"]
            console_url = config["console_addr"]
            username = config["username"]
            password = config["password"]

            auth_token = get_auth_token(console_url, username, password)
            get_forensics(console_name, console_url, auth_token)
    else:
        logger.warning("Incidents file not found.")
    logger.info("Prisma Cloud Compute poll_forensics script ending.")


if __name__ == "__main__":
    main()
