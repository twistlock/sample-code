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

from api_wrappers import get_auth_token, slash_join

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(levelname)s %(message)s")
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)

data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")
config_file = os.path.join(data_dir, "config.json")
incidents_file = os.path.join(data_dir, "incidents_list.txt")

def get_forensics(console_url, auth_token):
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

        for incident in incidents: incident["attempted"] = False
        while incidents:
            incident = incidents.pop(0)
            # If an incident has already been attempted, then we're back at the beginning of the list
            if incident["attempted"]:
                break

            incident["attempted"] = True
            incident["poll_attempts"] += 1
            logger.debug("Processing incidentID {}. Attempt #{}.".format(incident["_id"], incident["poll_attempts"]))
            params = {
                "project": incident["project"],
                "limit": request_limit,
                "incidentID": incident["_id"],
            }
            params_string = "&".join("{0}={1}".format(k, v) for k, v in params.items())
            request_url = slash_join(console_url, endpoint, incident["type"], incident["profileID"], "forensic")
            try:
                response = requests.get(request_url, params=params_string, headers=headers)
                response.raise_for_status()
                response_json = response.json()
                if response_json is not None:
                    logger.debug("Successfully processed incidentID {}.".format(incident["_id"]))
                    # Add incident ID to forensic data
                    for forensic in response_json:
                        forensic["incidentID"] = incident["_id"]
                        print(json.dumps(forensic))
            except (requests.exceptions.RequestException, ValueError) as req_err:
                logger.warning("Failed getting forensics for incidentID {} from profileID {}. Error: {}. Continuing.".format(incident["_id"], incident["profileID"], req_err))
                # Save for next time and keep going
                incidents.append(incident)
            except Exception as e:
                logger.error("Unexpected error: {}.".format(e))
                # Save for next time and keep going
                incidents.append(incident)

            # Keep file up-to-date with unprocessed incidents
            f.truncate(0)
            f.seek(0)
            json.dump(incidents, f)
            f.flush()

if __name__ == "__main__":
    logger.info("Prisma Cloud Compute poll_forensics script started.")
    if (os.path.isfile(incidents_file)):
        config = json.load(open(config_file))

        if not (config["console"]["url"] and config["credentials"]["username"] and config["credentials"]["password"]):
            logger.error("At least one item is missing in config.json. Please see README.md for more information. Exiting.")
            sys.exit(1)
        
        username = config["credentials"]["username"]
        password = config["credentials"]["password"]
        console_url = config["console"]["url"]

        auth_token = get_auth_token(console_url, username, password)
        get_forensics(console_url, auth_token)
    else:
        logger.warning("Incidents file not found.")
    logger.info("Prisma Cloud Compute poll_forensics script ending.")
