#
# Simple state to download and run the prisma cloud defender.sh script
# Example pillar config
#
# prisma_cloud_console:
#   ip: 1.2.3.4
#   port: 8083
#   user: admin
#   password: admin
#

{% set console_ip = (salt['pillar.get']('prisma_cloud_console:ip', '1.2.3.4')) -%}
{% set console_port = (salt['pillar.get']('prisma_cloud_console:port', '8083')) -%}
{% set console_user = (salt['pillar.get']('prisma_cloud_console:user', 'admin')) -%}
{% set console_password = (salt['pillar.get']('prisma_cloud_console:password', 'admin')) -%}

{% set tmp_dir = '/var/tmp/.twistlock' %}
{% set defender_script = tmp_dir + '/defender.sh' %}

install_curl:
  pkg.installed:
    - name: curl
    - refresh: True

create_tmp_dir:
  file.directory:
    - name: {{ tmp_dir }}

download_installer:
  cmd.run:
    - name: curl -s -k -X GET https://{{ console_user }}:{{ console_password }}@{{ console_ip }}:{{ console_port }}/api/v1/scripts/defender.sh > {{ defender_script }}
    - creates: {{ defender_script }}

make_executable:
  file.managed:
    - name: {{ defender_script }}
      mode: 755

run_defender_installer_docker:
  cmd.run:
    - name: {{ defender_script }} -d "docker"
    - onlyif: which docker

run_defender_installer_host:
  cmd.run:
    - name: {{ defender_script }} --install-host
    - unless: which docker
    - creates: /opt/twistlock/defender