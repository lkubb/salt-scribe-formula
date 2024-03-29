# vim: ft=sls

{#-
    Removes the scribe containers
    and the corresponding user account and service units.
    Has a depency on `scribe.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}

include:
  - {{ sls_config_clean }}

{%- if scribe.install.autoupdate_service %}

Podman autoupdate service is disabled for Scribe:
{%-   if scribe.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ scribe.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Scribe is absent:
  compose.removed:
    - name: {{ scribe.lookup.paths.compose }}
    - volumes: {{ scribe.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if scribe.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ scribe.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if scribe.install.rootless %}
    - user: {{ scribe.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Scribe compose file is absent:
  file.absent:
    - name: {{ scribe.lookup.paths.compose }}
    - require:
      - Scribe is absent

{%- if scribe.install.podman_api %}

Scribe podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman.socket
    - user: {{ scribe.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ scribe.lookup.user.name }}

Scribe podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman.socket
    - user: {{ scribe.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ scribe.lookup.user.name }}
{%- endif %}

Scribe user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ scribe.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ scribe.lookup.user.name }}

Scribe user account is absent:
  user.absent:
    - name: {{ scribe.lookup.user.name }}
    - purge: {{ scribe.install.remove_all_data_for_sure }}
    - require:
      - Scribe is absent
    - retry:
        attempts: 5
        interval: 2

{%- if scribe.install.remove_all_data_for_sure %}

Scribe paths are absent:
  file.absent:
    - names:
      - {{ scribe.lookup.paths.base }}
      - {{ scribe.lookup.paths.src }}
    - require:
      - Scribe is absent
{%- endif %}
