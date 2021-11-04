import json
import requests


def login_api():
    global prisma_token
    global base_url

    base_url = '' # fill in URL for talking to Compute Console

    login_info_hash = {
            'username': '', #access key or username
            'password': '' #access key secret or password
    }
    headers = {'Content-Type': 'application/json'}

    login_info = json.dumps(login_info_hash)
#had to add verify=False due to PyCharm
    response_json = requests.post(base_url + '/api/v1/authenticate', login_info, headers=headers, verify=False)

    prisma_token = response_json.json()['token']

    auth_headers = {'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + prisma_token}
    return auth_headers

def list_backups(auth_headers):
    # List all known backups (including built-in backups)
    url = '/api/v1/backups'
    response = requests.get(base_url + url, headers=auth_headers, verify=False)
    count=0
    print ("Backups:")
    for backup in response.json():
        print("Name: {}".format(backup['name']))
        print("Release: {}".format(backup['release']))
        print("Time: {}".format(backup['time']))
        print("Id: {}\n".format(backup['id']))
        count +=1
    print ("Total backups: {}".format(count))


def create_backup(auth_headers):
    #Create backup with name: eddie_test2
    url = '/api/v1/backups'
    payload = '"eddie_test2"'  #name of backup file
    response = requests.post(base_url + url, data=payload, headers=auth_headers, verify=False)
    print (response.json())

def download_backup(auth_headers):
    url = '/api/v1/backups/'
    id = 'eddie_test2-20.04.177-1594329052.tar.gz'  #id which is the file name set when a backup is run
    response = requests.get(base_url + url + id, headers=auth_headers, verify=False)
    filename = id
    print(filename)
    with open(filename, 'wb') as f:
        f.write(response.content)

def delete_backup(auth_headers):
    url = '/api/v1/backups/'
    id = 'eddie_test2-20.04.177-1594329089.tar.gz' #id aka filename to delete
    response = requests.delete(base_url + url + id, headers=auth_headers, verify=False)
    print(response.status_code)

if __name__ == '__main__':
    auth_headers=login_api()
    list_backups(auth_headers)
    create_backup(auth_headers)
    download_backup(auth_headers)
    delete_backup(auth_headers)
