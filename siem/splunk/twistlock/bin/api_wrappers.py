from __future__ import print_function
import base64
import json
import requests
import sys

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

    return response_json['token']

# Wrapper around /api/v1/current/projects
# Sample output:
# [{"_id":"string","address":"string","creationTime":"string","connected":Boolean}
# ,{"_id":"string","address":"string","creationTime":"string","connected":Boolean}
# ]
# Remark: Even if the user is permitted to Central Console, Central Console will not be an element in the response.
# A user can have access to 1) all projects or 2) a subset of projects not including the Central Console
def get_projects(console_url, auth_token):
    projects = []

    # A user's permitted projects are listed in the JWT payload
    # Load the decoded JWT payload to get available projects
    # https://stackoverflow.com/a/49459036
    jwt_payload = json.loads(base64.b64decode(auth_token.split('.')[1] + "==="))

    # Address case in which user has permission to all projects
    # Otherwise Central Console would not be added to projects list
    if jwt_payload["permissions"][0]["project"] == "Central Console":
        projects.append("Central Console")

    endpoint = "/api/v1/current/projects"
    # jwt_payload["permissions"][0]["project"] ensures that the project specified is one the user is permitted to access
    params = {"project":  jwt_payload["permissions"][0]["project"]}
    headers = {"Authorization": "Bearer " + auth_token, "Accept": "application/json"}
    request_url = console_url + endpoint

    try:
        response = requests.get(request_url, params=params, headers=headers)
        response.raise_for_status()
        response_json = response.json()
    except (requests.exceptions.RequestException, ValueError) as req_err:
        print("Failed getting projects", file=sys.stderr)
        sys.exit(req_err)

    for item in response_json:
        projects.append(item["_id"])

    return projects
