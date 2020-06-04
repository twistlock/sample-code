Bamboo
======

Overview
--------

Using Bamboo you can create a Docker task to build your image.  You can then follow that up with a Script task to download and run the `twistcli` binary.

That would take in some options you can securely pass to the job, here they are called out at the beginning:

```
CONSOLE=https://my_twistlock_console:port
USER=my_twistlock_user_with_ci_role
PASSWORD=my_twistlock_users_password

curl -u ${USER}:${PASSWORD} --output ./twistcli ${CONSOLE}/api/v1/util/twistcli
chmod +x ./twistcli
./twistcli images scan --address ${CONSOLE} -u ${USER} -p ${PASSWORD} my_image_created/in_the_previous:task
```
