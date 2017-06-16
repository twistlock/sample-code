# README
## Caveats!
* I've only tested this on CentOS 7.
* Please feel free offer changes

## Running it
This is a draft playbook to generate a lab machine

* You've spun up a host, you have your user and your key on it; you've created a file called ```inventory``` or ```hosts``` and have populated with the IP/DNS (or you have already done this with your default hosts file)
* Update the ```license_file.json``` with the appropriate license information
  * My default setting is that this file is in the ```.gitignore``` file so that you don't accidentally commit your license.
* Run it - ```ansible-playbook -i <your_hosts_file> ./site.yml```
* *Note that the admin password gets changed to something random!* the last play should tell you:

```
TASK [Let the user know the password] ******************************************
ok: [104.199.34.58] => {
        "msg": "System 104.199.34.58 has an admin password of G#IN5YCP"
}
```
