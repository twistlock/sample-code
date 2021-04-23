#!/usr/bin/env python
import argparse
import logging
import os
import glob
import sys
import requests
from requests.exceptions import RequestException
import json
import datetime, time
from pathlib import Path
import shutil
import io
import urllib, base64

import matplotlib.pyplot as plt
from jinja2 import Environment, FileSystemLoader
import pdfkit

COMPUTE_CONSOLE_ADDRESS = os.environ.get('COMPUTE_CONSOLE_ADDRESS')
COMPUTE_ACCESS_KEY = os.environ.get('COMPUTE_ACCESS_KEY')
COMPUTE_SECRET_KEY = os.environ.get('COMPUTE_SECRET_KEY')
API_VERSION = "v1"
VERIFY_SSL=False
# Defaults to max 10,000 images
IMAGE_TYPES = ['deployed', 'registry', 'ci']
PAGE_LIMIT=50
MAX_PAGES=200
TEMPLATES_DIR=f'{os.path.dirname(os.path.realpath(__file__))}/templates'

now = datetime.datetime.now()

HEADERS = {
    'accept': 'application/json; charset=UTF-8',
    'content-type': 'application/json'
}


def pretty_print_request(req):
    logging.debug('{}\n{}\n{}\n\n{}\n\n'.format(
        '-----------START-----------',
        req.method + ' ' + req.url,
        '\n'.join('{}: {}'.format(k, v) for k, v in req.headers.items()),
        req.body,
    ))


def make_api_call(method, url, data=None, params=None):
    logging.debug('Fetching {}'.format(url))
    try:
        req = requests.Request(method, url, params=params, data=data, headers=HEADERS)
        prepared = req.prepare()
        pretty_print_request(prepared)

        session = requests.Session()
        resp = session.send(prepared, verify=VERIFY_SSL)
        if resp.status_code == 200:
            return resp.content
        else:
            return None
    except RequestException as e:
        logging.error('Error during requests to {}: {}'.format(url, str(e)))


def compute_login():
    login_creds = json.dumps({
        "username": COMPUTE_ACCESS_KEY,
        "password": COMPUTE_SECRET_KEY
    })
    login_response = make_api_call('POST', f'{COMPUTE_CONSOLE_ADDRESS}/api/{API_VERSION}/authenticate', login_creds)
    logging.debug(f'login_response: {login_response}')
    response = json.loads(login_response)
    return response.get('token')


def get_images(token, image_type):
    if image_type == "deployed":
        endpoint = "images"
    elif image_type == "registry":
        endpoint = "registry"
    elif image_type == "ci":
        endpoint = "scans"

    HEADERS['Authorization'] = f'Bearer {token}'
    all_images = []
    for page in range(MAX_PAGES):
        logging.debug(f'Fetching /images page {page}')
        params = {
            "limit": PAGE_LIMIT,
            "offset": page,
            "reverse": "false"
        }
        if image_type == "ci":
            params['type'] = "ciImage"

        images_response = make_api_call('GET', f'{COMPUTE_CONSOLE_ADDRESS}/api/{API_VERSION}/{endpoint}', params=params)
        # logging.debug(f'images_response: {images_response}')
        try:
            images = json.loads(images_response)
            logging.debug(f'Found {len(images)} images')
            all_images += images
        except ValueError:
            logging.error(f'images_response is not valid json: {images_response}')
            sys.exit(1)
        if len(images) < PAGE_LIMIT:
            logging.debug('Last Page, exiting loop')
            break
    return all_images


def get_vulnerabilities(images):
    vulnerabilities = {}
    vulnerability_count = 0
    for image in images:
        if image.get('vulnerabilities') is not None:
            for vulnerability in image.get("vulnerabilities", []):
                vulnerability_count += 1
                if not vulnerabilities.get(vulnerability.get('cve')):
                    vulnerabilities[vulnerability.get('cve')] = vulnerability
                    vulnerabilities[vulnerability.get('cve')]['failed_resources'] = []
                # TODO: instances are not deduped here, they should be.
                vulnerabilities[vulnerability.get('cve')]['failed_resources'] += image.get('instances')
    return vulnerability_count, vulnerabilities


def get_compliance_issues(images):
    compliance_issues = {}
    compliance_issue_count = 0
    for image in images:
        if image.get('complianceIssues') is not None:
            for compliance_issue in image.get('complianceIssues', []):
                compliance_issue_count += 1
                if not compliance_issues.get(compliance_issue.get('id')):
                    compliance_issues[compliance_issue.get('id')] = compliance_issue
                    compliance_issues[compliance_issue.get('id')]['failed_resources'] = []
                # TODO: instances are not deduped here, they should be.
                compliance_issues[compliance_issue.get('id')]['failed_resources'] += image.get('instances')
    return compliance_issue_count, compliance_issues


def generate_vuln_summary(images, vulnerabilities):
    crit_vuln = []
    high_vuln = []
    med_vuln = []
    low_vuln = []
    unkown_vuln = []
    for cve, vulnerability in vulnerabilities.items():
        #TODO: This dedupes the instances in 'failed_resources', it should be done before we get here
        failed_resources = list(map(dict, set(tuple(sorted(sub.items())) for sub in vulnerability['failed_resources'])))
        vulnerability['failed_resources'] = failed_resources
        vulnerability['percentage_failed'] = int((len(failed_resources) / len(images)) * 100)
        logging.debug(f'{vulnerability.get("severity")} {cve} {len(vulnerability["failed_resources"])}')
        if vulnerability.get("severity") in ("critical", "important"):
            crit_vuln.append(vulnerability)
        elif vulnerability.get("severity") == "high":
            high_vuln.append(vulnerability)
        elif vulnerability.get("severity") in ("medium", "moderate"):
            med_vuln.append(vulnerability)
        elif vulnerability.get("severity") == "low":
            low_vuln.append(vulnerability)
        else:
            unkown_vuln.append(vulnerability)        

    crit_vuln.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    high_vuln.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    med_vuln.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    low_vuln.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    unkown_vuln.sort(key=lambda x: len(x['failed_resources']), reverse=True)

    severity_count = {
        "critical": len(crit_vuln),
        "high": len(high_vuln),
        "medium": len(med_vuln),
        "low": len(low_vuln)
    }
    all_vuln = crit_vuln + high_vuln + med_vuln + low_vuln + unkown_vuln
    return severity_count, all_vuln


def generate_comp_summary(images, compliance_issues):
    crit_comp = []
    high_comp = []
    med_comp = []
    low_comp = []
    unkown_comp = []
    for id, compliance_issue in compliance_issues.items():
        #TODO: This dedupes the instances in 'failed_resources', it should be done before we get here
        failed_resources = list(map(dict, set(tuple(sorted(sub.items())) for sub in compliance_issue['failed_resources'])))
        compliance_issue['failed_resources'] = failed_resources
        compliance_issue['percentage_failed'] = int((len(failed_resources) / len(images)) * 100)
        logging.debug(f'{compliance_issue.get("severity")} {compliance_issue.get("title")} {len(compliance_issue["failed_resources"])}')
        if compliance_issue.get("severity") == "critical":
            crit_comp.append(compliance_issue)
        elif compliance_issue.get("severity") == "high":
            high_comp.append(compliance_issue)
        elif compliance_issue.get("severity") == "med":
            med_comp.append(compliance_issue)
        elif compliance_issue.get("severity") == "low":
            low_comp.append(compliance_issue)
        else:
            unkown_comp.append(compliance_issue)

    crit_comp.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    high_comp.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    med_comp.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    low_comp.sort(key=lambda x: len(x['failed_resources']), reverse=True)
    unkown_comp.sort(key=lambda x: len(x['failed_resources']), reverse=True)

    severity_count = {
        "critical": len(crit_comp),
        "high": len(high_comp),
        "medium": len(med_comp),
        "low": len(low_comp)
    }
    all_comp = crit_comp + high_comp + med_comp + low_comp + unkown_comp
    return severity_count, all_comp


def generate_pie_chart(chart, data):
    labels = []
    values = []
    invalid = True
    for label, value in data.items():
        if value > 0:
            invalid = False
        labels.append(label)
        values.append(value)

    if invalid:
        # We want at least one non zero value
        return 'static/images/none-chart.png'

    explode = (0, 0, 0, 0)
    colors = ["#90251c", "#dd3d2d", "#ea9a33", "#e6dd37"]

    fig1, ax1 = plt.subplots()
    ax1.pie(values, explode=explode, labels=labels, autopct='%1.1f%%',
            shadow=True, startangle=90, colors=colors)
    ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    filename = f'static/tmp/{chart}.png'
    plt.savefig(f'templates/{filename}')
    return filename


def generate_html_files(html):
    report_dir = now.strftime('%Y-%m-%d-%H-%M-%S')
    Path(f"reports/{report_dir}").mkdir(parents=True, exist_ok=True)
    shutil.copytree("templates/static", f"reports/{report_dir}/static")
    f = open(f"reports/{report_dir}/Report.html", "w")
    f.write(html)
    f.close()


def generate_html(
    env,
    image_type,
    images,
    vulnerability_count,
    compliance_issue_count,
    vulnerabilities,
    compliance_issues,
    summary,
    vulnerabilities_only,
    compliance_only):
    timestamp = time.strftime("%Y-%m-%d at %H:%M:%S", time.localtime())
    template = env.get_template("base.html")
    vuln_severity_count, vuln_list = generate_vuln_summary(images, vulnerabilities)
    comp_severity_count, comp_list = generate_comp_summary(images, compliance_issues)
    vuln_dist_chart = generate_pie_chart('vuln', vuln_severity_count)
    comp_dist_chart = generate_pie_chart('comp', comp_severity_count)
    html = template.render(
        templates_dir=TEMPLATES_DIR,
        image_type=image_type,
        resource_count=len(images),
        timestamp=timestamp,
        console_address=COMPUTE_CONSOLE_ADDRESS,
        vulnerability_count=vulnerability_count,
        compliance_issue_count=compliance_issue_count,
        vuln_dist_chart=vuln_dist_chart,
        comp_dist_chart=comp_dist_chart,
        vulnerability_list=vuln_list,
        compliance_list=comp_list,
        vulnerabilities=vulnerabilities,
        compliance_issues=compliance_issues,
        summary=summary,
        vuln_only=vulnerabilities_only,
        comp_only=compliance_only
        )
    return html


def generate_pdf(html):
    report_dir = now.strftime('%Y-%m-%d-%H-%M-%S')
    Path(f"reports/{report_dir}").mkdir(parents=True, exist_ok=True)
    options = {
        'page-size': 'Letter',
        'margin-top': '0',
        'margin-right': '0',
        'margin-bottom': '0',
        'margin-left': '0',
        'encoding': "UTF-8",
        'custom-header' : [
            ('Accept-Encoding', 'gzip')
        ],
        'allow': ["templates", "/tmp"],
        'enable-local-file-access': None,
        'keep-relative-links': None
    }
    pdfkit.from_string(html, f'reports/{report_dir}/Report.pdf', options=options)


def cleanup():
    files = glob.glob('templates/static/tmp/*.png')
    for f in files:
        try:
            os.remove(f)
        except OSError as e:
            logging.error(f"Error: {f} : {e.strerror}")


def main(image_type, file_format, summary, vulnerabilities_only, compliance_only):
    token = compute_login()
    images = get_images(token, image_type)
    logging.info(f"Images found: {len(images)}")
    vulnerability_count, vulnerabilities = get_vulnerabilities(images)
    compliance_issue_count, compliance_issues = get_compliance_issues(images)

    file_loader = FileSystemLoader('templates')
    env = Environment(loader=file_loader)

    html = generate_html(
        env,
        image_type,
        images,
        vulnerability_count,
        compliance_issue_count,
        vulnerabilities,
        compliance_issues,
        summary,
        vulnerabilities_only,
        compliance_only
    )

    if file_format == "html":
        generate_html_files(html)
    else:
        generate_pdf(html)
    cleanup()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create Compute Reports",
        formatter_class=lambda prog: argparse.HelpFormatter(prog,max_help_position=80)
    )
    parser.add_argument(
        "-t", "--type", type=str, default="deployed", choices=['deployed', 'registry', 'ci'],
        help="Used to select the type of report to run.")
    parser.add_argument(
        "-f", "--format", type=str, default="pdf", choices=['pdf', 'html'],
        help="Selects the file format of the generated report.")
    parser.add_argument(
        "-d", "--debug", action='store_true',
        help="Prints debug output during report creation")

    parser.add_argument(
        "-s", "--summary", action='store_true',
        help="Summary only, do not include vulnerability or compliance details"
    )

    parser.add_argument(
        "-vo", "--vulnerabilities-only", action='store_true',
        help="Exclude Compliance data from report"
    )

    parser.add_argument(
        "-co", "--compliance-only", action='store_true',
        help="Exclude Vulnerabilities data from report"
    )

    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    # main(image_type, outfile, file_format)
    main(args.type, args.format, args.summary, args.vulnerabilities_only, args.compliance_only)