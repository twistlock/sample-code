# import json
import requests
from requests.auth import HTTPBasicAuth
import os, sys
import simplejson as json
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

url = os.environ['TL_CONSOLE']
api = url + '/api/v1/authenticate'
pw = os.environ['TL_USER_PW']
user = os.environ['TL_USER']
data = {'username': user, 'password': pw}

searchOn = False
searchStr = ""
outFile = "modelIDs"

if  len(sys.argv) > 1:
    searchOn = True
    searchStr = sys.argv[1]
    outFile += "-" + searchStr

outFile += '.txt'

# print("Get token using: ", data)
response = requests.post(api, json=data, verify=False)

TOKEN = response.json()['token']
# print(TOKEN)
bearer = "Bearer " + TOKEN
HEADERS = {'content-type':'application/json', 'Authorization': bearer}

with requests.Session() as s:
    s.verify = True

    if searchOn:
        print("--- retrieving all model profiles that match " + searchStr)
    else:
        print("--- retrieving all model profiles")
        
    s.headers.update(HEADERS)
    api = url + '/api/v1/profiles/container'
    if searchOn:
        api += "?search=" + searchStr
    response = s.get(api, verify=False)
    print(response)
    idFile = open(outFile, 'w')
    first = True
    for i in response.json():
         # print("model id:" + i['_id'])
        if( not first ):
            idFile.write("\n")
        idFile.write(i['_id'])
        first = False
        
    idFile.close()

print("--- model ids written to file " + outFile)
       


    





