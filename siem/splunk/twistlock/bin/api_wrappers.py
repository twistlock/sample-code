import json
import requests
import sys
from __future__ import print_function

# Wrapper around /api/v1/authenticate
# Even when using projects, /api/v1/authenticate should still hit against Central Console
def get_auth_token(console_url, username, password):
    endpoint = "/api/v1/authenticate"
    params = {"project": "Central Console"}
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    data = {"username": username, "password": password}
    request_url = console_url + endpoint

    try:
        response = requests.post(request_url, params=params, headers=headers, data=json.dumps(data))
        response.raise_for_status()
        response_json = response.json()
    except (requests.exceptions.RequestException, ValueError) as req_err:
        print("Failed getting auth token", file=sys.stderr)
        sys.exit(req_err)

    return response_json

# Wrapper around /api/v1/projects
# Requires Twistlock admin user
def get_projects(console_url, auth_token):
    endpoint = "/api/v1/projects"
    params = {"project": "Central Console"}
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_url = console_url + endpoint

    try:
        response = requests.get(request_url, params=params, headers=headers)
        response.raise_for_status()
        response_json = response.json()
    except (requests.exceptions.RequestException, ValueError) as req_err:
        print("Failed getting projects", file=sys.stderr)
        sys.exit(req_err)

    return response_json
