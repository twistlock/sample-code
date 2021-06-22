import logging
import sys

import splunk.entity as entity

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(levelname)s %(message)s")
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)


def get_credentials(session_key):
    try:
        entities = entity.getEntities(
            ["storage", "passwords"], namespace="twistlock",
            owner="nobody", sessionKey=session_key)
    except Exception as e:
        logger.error("Failed getting credentials from Splunk: %r", e)

    credentials = []
    for item in entities.values():
        credential = {
            "username": item["username"],
            "password": item["clear_password"],
            "realm": item["realm"],
        }
        credentials.append(credential)
    return credentials


def get_config_stanza(realm, session_key):
    try:
        entities = entity.getEntities(
            ["configs", "conf-twistlock", realm], namespace="twistlock",
            owner="nobody", sessionKey=session_key)
        conf_values = entities[realm]
    except Exception as e:
        logger.error("Failed getting configuration from Splunk: %r", e)

    stanza = {
        "console_addr": conf_values["console_addr"],
        "username": conf_values["username"],
    }

    if "projects" in conf_values and conf_values["projects"] is not None:
        stanza["projects"] = conf_values["projects"].split(",")
    else:
        stanza["projects"] = "all"

    return stanza


def generate_configs(session_key):
    configs = []
    credentials = get_credentials(session_key)
    for credential in credentials:
        stanza = get_config_stanza(credential["realm"], session_key)
        stanza.update(credential)
        configs.append(stanza)
    return configs
