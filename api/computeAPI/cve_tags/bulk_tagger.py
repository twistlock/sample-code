import argparse
import csv
from datetime import datetime
import json
import os
import requests
import sys

# Disables warning from 'verify=False' in requests.post method call
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

argparser = argparse.ArgumentParser(description='Bulk add tags to CVEs in Prisma Cloud Compute', epilog='Example: `python3 ./bulk_tagger.py https://my.console.url:8083 tags.csv -u admin -p password123`')
argparser.add_argument('console_url', help='the Console address without trailing \'/\'', metavar='CONSOLE_URL')
argparser.add_argument('csv_filename', help='the CSV file with the following header: tag,cve,packageName,comment', metavar='CSV_FILENAME')
argparser.add_argument('-u', '--username', help='username for authentication to Compute (overrides COMPUTE_USER environment variable)', metavar='USERNAME')
argparser.add_argument('-p', '--password', help='password for authentication to Compute (overrides COMPUTE_PASS environment variable)', metavar='PASSWORD')
argparser.add_argument('-t', '--token', help='API token for authentication to Compute (overrides COMPUTE_TOKEN environment variable)', metavar='TOKEN')

args = argparser.parse_args()

console_url = args.console_url
csv_filename = args.csv_filename

# Use user-provided flag value if exists, else use environment variable
console_user = os.environ['COMPUTE_USER'] if 'COMPUTE_USER' in os.environ and args.username is None else args.username
console_pass = os.environ['COMPUTE_PASS'] if 'COMPUTE_PASS' in os.environ and args.password is None else args.password
console_token = os.environ['COMPUTE_TOKEN'] if 'COMPUTE_TOKEN' in os.environ and args.token is None else args.token

if console_token is None:
    if console_user is None:
        print('\n*** No username supplied. Exiting. ***\n', file=sys.stderr)
        argparser.print_help(sys.stderr)
        exit(1)
    if console_pass is None:
        print('\n*** No password supplied. Exiting. ***\n', file=sys.stderr)
        argparser.print_help(sys.stderr)
        exit(1)

    credentials = {"username": console_user, "password": console_pass}
    auth_response = requests.post(console_url + "/api/v1/authenticate", headers={"Content-Type": "application/json"}, data=json.dumps(credentials), verify=False)
    try:
        console_token = auth_response.json()['token']
    except ValueError:
        print("ValueError with URL:", console_url + "/api/v1/authenticate", file=sys.stderr)
        exit(1)

post_counter = 0
with open(csv_filename, newline='') as csv_file, open('tmp.csv', 'w') as tmp_csv:
    csv_reader = csv.DictReader(csv_file)
    try:
        assert csv_reader.fieldnames == ['tag', 'cve', 'packageName', 'comment', 'timeAdded'], '\n*** CSV file ' + csv_filename + ' does not have a proper heading row (tag,cve,packageName,comment,timeAdded) ***\n'
    except AssertionError as e:
        print(e, file=sys.stderr)
        exit(1)

    csv_writer = csv.DictWriter(tmp_csv, fieldnames=csv_reader.fieldnames)
    csv_writer.writeheader()

    print('POSTing the following items:\n')
    for row in csv_reader:
        if row['timeAdded']:
            csv_writer.writerow(row)
            continue

        tag = row['tag']
        payload = {'id': row['cve'], 'packageName': row['packageName'], 'comment': row['comment'] or row['tag']}
        
        tag_endpoint = '/api/v1/tags/' + tag + '/vuln'
        tag_post = requests.post(console_url + tag_endpoint, headers={"Authorization": "Bearer " + console_token}, data=json.dumps(payload), verify=False)

        try:
            tag_post.raise_for_status()
        except:
            print('POST failed with status code ' + str(tag_post.status_code) + '. Please make sure tag ' + tag + ' exists under Manage > Collections and Tags > Collections.', file=sys.stderr)
        else:
            print('POST succeeded.')
            row['timeAdded'] = datetime.now().isoformat(timespec='milliseconds')
            post_counter += 1

        csv_writer.writerow(row)
        print('  tag: {tag}\n  cve: {id}\n  package: {packageName}\n  comment: {comment}\n'.format(tag=tag, **payload))

os.remove(csv_filename)
os.rename('tmp.csv', csv_filename)
print('POSTing complete. POSTed ' + str(post_counter) + ' items.')