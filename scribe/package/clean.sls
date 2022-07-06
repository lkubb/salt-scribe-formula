# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as scribe with context %}

include:
  - {{ sls_config_clean }}

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

Scribe user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ scribe.lookup.user.name }}
    - enable: false

Scribe user account is absent:
  user.absent:
    - name: {{ scribe.lookup.user.name }}
    - purge: {{ scribe.install.remove_all_data_for_sure }}
    - require:
      - Scribe is absent

{%- if scribe.install.remove_all_data_for_sure %}

Scribe paths are absent:
  file.absent:
    - names:
      - {{ scribe.lookup.paths.base }}
      - {{ scribe.lookup.paths.src }}
    - require:
      - Scribe is absent
{%- endif %}
