import os
from configparser import ConfigParser 

poll_incidents_script = os.path.join("script://.","bin","poll_incidents.py") 
poll_forensics_script = os.path.join("script://.","bin","poll_forensics.py") 
data_dir = os.path.join(os.environ["SPLUNK_HOME"], "etc", "apps", "twistlock","default")
inputs_file =  os.path.join(data_dir,"inputs.conf")
props_file =  os.path.join(data_dir,"props.conf")
app_file =  os.path.join(data_dir,"app.conf")
config = ConfigParser()

config[poll_incidents_script] = {
    'disabled': '1',
    'sourcetype': 'pcc:incident',
    'interval': '0 * * * *',
    'start_by_shell': '0'
}

config[poll_forensics_script] = {
    'disabled': '1',
    'sourcetype': 'pcc:forensicdata',
    'interval': '5 * * * *',
    'start_by_shell': '0'
}

with open (inputs_file, 'w') as inputsfile:
    config.write(inputsfile)

config = ConfigParser()

config["pcc:incident"] = {
    'category': 'Custom',
    'description': 'Incident output produced by the Prisma Cloud Compute Console API',
    'EXTRACT-t_id': '"_id":\s"(?P<t_id>[a-f0-9]+)"',
    'EXTRACT-t_containerid': '"containerID":\s"(?P<t_containerid>[a-f0-9]{\8})[a-f0-9]+"',
    'TIME_PREFIX': '"time":',
    'TIME_FORMAT': '%Y-%m-%\dT%H:%M:%S.%9N%Z',
    'KV_MODE': 'json',
    'SHOULD_LINEMERGE': 'false',
    'TZ': 'UTC'    
}

config["pcc:forensicdata"] = {
    'category': 'Custom',
    'description': 'Forensic output produced by the Prisma Cloud Compute Console API',
    'TIME_PREFIX': '"timestamp":',
    'TIME_FORMAT': '%Y-%m-%\dT%H:%M:%S.%9N%Z',
    'KV_MODE': 'json',
    'SHOULD_LINEMERGE': 'false',
    'TZ': 'UTC'
}

with open (props_file, 'w') as propsfile:
    config.write(propsfile)

config = ConfigParser()

config["launcher"]={
    'author': 'PaloAltoNetworks',
    'description': 'Prisma Cloud Compute (formerly Twistlock) integration into Splunk',
    'version': '3.2.1'
}

config["package"]={
    'id': 'twistlock'
}

config["ui"]={
    'is_visible': '1',
    'label': 'Prisma Cloud Compute'
}

with open (app_file, 'w') as appfile:
    config.write(appfile)


