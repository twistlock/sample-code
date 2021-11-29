#!/usr/bin/env python3

import sys
import getpass
import argparse
import json
import os
import requests
from requests.auth import HTTPBasicAuth
from jinja2 import Template


class imgRequestError(Exception):
    pass


def parse_args():
    """
    CLI argument handling
    """

    desc = 'Generate an HTML report of CVEs per image, displaying the data to STDOUT/n'

    epilog = 'The console and user arguments can be supplied using the environment variables TL_CONSOLE and TL_USER.'
    epilog += ' The password can be passed using the environment variable TL_USER_PW.'
    epilog += ' The user will be prompted for the password when the TL_USER_PW variable is not set.'
    epilog += ' Environment variables override CLI arguments.'

    p = argparse.ArgumentParser(description=desc,epilog=epilog)
    p.add_argument('-c','--console',metavar='TL_CONSOLE', help='query the API of this Console')
    p.add_argument('-u','--user',metavar='TL_USER',help='Console username')
    p.add_argument('-p','--password',metavar='TL_USER_PW',help='Console Password')

    args = p.parse_args()

    # Populate args by env vars if they're set
    envvar_map = {'TL_USER':'user','TL_CONSOLE':'console','TL_USER_PW':'password'}
    for evar in envvar_map.keys():
        evar_val = os.environ.get(evar,None)
        if evar_val is not None:
            setattr(args,envvar_map[evar],evar_val)

    arg_errs = []
    if getattr(args,'console',None) is None:
        arg_errs.append('console (-c,--console)')
    if getattr(args,'user',None) is None:
        arg_errs.append('user (-u,--user)')
    if getattr(args,'password',None) is None:
        arg_errs.append('user (-p,--password)')

    if len(arg_errs) > 0:
        err_msg = 'Missing argument(s): {}'.format(', '.join(arg_errs))
        p.error(err_msg)

    if getattr(args,'password',None) is None:
        args.password = getpass.getpass('Enter password: ')

    return args

def generate_html(images_json):
    "This converts the images API output to HTML"
    report_body_template = open("report_body_ci.html.j2").read()
    template = Template(report_body_template)
    output_html = template.render(images=images_json)
    return output_html

def get_images_json(console,user,password):
    api_endpt = '/api/v1/scans?type=ciImage&jobNameHello-Node&limit=1&offset=0'
    request_url = console + api_endpt
    image_req = requests.get(request_url, verify=False, auth=HTTPBasicAuth(user,password))
    if image_req.status_code != 200:
        # This means something went wrong.
        raise imgRequestError('GET /api/v1/scans {} {}'.format(image_req.status_code,image_req.reason))
    return image_req.json()

def main():

    args = parse_args()

    try:
        images_json = get_images_json(args.console,args.user,args.password)

    except imgRequestError as e:
        print("Error querying API: {}".format(e))
        return 3

    
    
    
    #print(images_json)

    output_html = generate_html(images_json)
    print(output_html, file=open("reportCI.html", "w"))

    return 0

if __name__ == '__main__':
    sys.exit(main())
