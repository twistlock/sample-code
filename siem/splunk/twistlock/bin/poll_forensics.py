from __future__ import print_function
import json
import os
import sys
import requests
try:
    from urllib.parse import urljoin
except ImportError:
    from urlparse import urljoin
from api_wrappers import get_auth_token


data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock", "bin", "data")
# config_file - stores the Console URL and authentication information
config_file = os.path.join(data_dir, "config.json")

incidents_file = os.path.join(data_dir, "incidents_list.txt")

def get_forensics(console_url, auth_token):
    endpoint = "/api/v1/profiles/"
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_limit = 100

    with open(incidents_file, "r+") as f:
        incidents = json.load(f)
        while incidents:
            incident = incidents.pop(0)
            params = {"project": incident["project"], "limit": request_limit, "incidentID": incident["_id"]}
            params_string = "&".join("%s=%s" % (k,v) for k,v in params.items())
            api_path = endpoint + incident["type"] + "/" + incident["profileID"] + "/forensic"
            if console_url == incident["url"]:
                request_url = urljoin(console_url, api_path)
                try:
                    response = requests.get(request_url, params=params_string, headers=headers, verify=False, timeout=0.25)
                    response.raise_for_status()
                    response_json = response.json()
                except (requests.exceptions.RequestException, ValueError) as req_err:
                    print("Failed getting forensics\nincidentID: {}\nprofileID: {}\n{}".format(incident["_id"], incident["profileID"], req_err), file=sys.stderr)
                    continue

                if response_json is not None:
                    # Add incident ID to forensic data
                    for forensic in response_json:
                        forensic["console"] = console_url
                        forensic["incidentID"] = incident["_id"]
                        print(json.dumps(forensic))

                # Keep file up-to-date with unprocessed incidents
                f.truncate(0)
                f.seek(0)
                json.dump(incidents, f)
                f.flush()


if __name__ == "__main__":
    if (os.path.isfile(incidents_file)):
        config = json.load(open(config_file))

        if not (config["consoles"][0]["url"] and config["consoles"][0]["credentials"]["username"] and config["consoles"][0]["credentials"]["password"]):
            print("At least one item is missing in config.json", file=sys.stderr)
            sys.exit(1)
        for console in range(0,len(config["consoles"])):
            username = config["consoles"][console]["credentials"]["username"]
            password = config["consoles"][console]["credentials"]["password"]
            console_url = config["consoles"][console]["url"]
            auth_token = get_auth_token(console_url, username, password)
            get_forensics(console_url, auth_token)

        os.remove(incidents_file)
    else:
        print("Incidents file not found", file=sys.stderr)


